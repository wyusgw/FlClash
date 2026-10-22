import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, posix } from 'node:path';

const [out, siteArg, root] = process.argv.slice(2);
if (!out || !siteArg || !root) {
  console.error('usage: render_docs.mjs <site dir> <site url> <repository root>');
  process.exit(64);
}
const siteUrl = new URL(siteArg.replace(/\/*$/, '/')).href;
const REPO = 'https://github.com/wyusgw/FlClash';

// Each document, the page it becomes, and the documents that are its translations.
const USER_GUIDES = ['docs/user-guide.md', 'docs/user-guide.zh-CN.md', 'docs/user-guide.zh-TW.md'];
const DOCS = [
  { source: 'docs/user-guide.md', page: 'docs/user-guide/', lang: 'en', pairs: USER_GUIDES.filter((s) => s !== 'docs/user-guide.md') },
  { source: 'docs/user-guide.zh-CN.md', page: 'zh/docs/user-guide/', lang: 'zh', pairs: USER_GUIDES.filter((s) => s !== 'docs/user-guide.zh-CN.md') },
  { source: 'docs/user-guide.zh-TW.md', page: 'zh-tw/docs/user-guide/', lang: 'zh-tw', pairs: USER_GUIDES.filter((s) => s !== 'docs/user-guide.zh-TW.md') },
  { source: 'CONTRIBUTING.md', page: 'docs/contributing/', lang: 'en' },
  { source: 'docs/architecture.md', page: 'docs/architecture/', lang: 'en' },
];
const PAGE_OF = new Map(DOCS.map((doc) => [doc.source, doc.page]));

const INDEXES = [
  {
    lang: 'en',
    page: 'docs/',
    title: 'Documentation',
    intro: 'Guides for using, building and changing FlClash.',
    entries: [
      ['docs/user-guide.md', 'User guide', 'Adding servers, routing rules, DNS, TUN, hotkeys, backup and troubleshooting.'],
      ['docs/user-guide.zh-CN.md', '用户指南(简体中文)', 'The user guide in Simplified Chinese.'],
      ['docs/user-guide.zh-TW.md', '使用指南(繁體中文)', 'The user guide in Traditional Chinese.'],
      ['CONTRIBUTING.md', 'Contributing', 'Building, testing, commit messages and releasing.'],
      ['docs/architecture.md', 'Architecture', 'How the app, the Go core and the native services fit together.'],
    ],
  },
  {
    lang: 'zh',
    page: 'zh/docs/',
    title: '文档',
    intro: 'FlClash 的使用、构建与开发文档。',
    entries: [
      ['docs/user-guide.zh-CN.md', '使用指南', '添加服务器、路由规则、DNS、虚拟网卡、快捷键、备份与常见问题。'],
      ['docs/user-guide.zh-TW.md', '使用指南(繁體中文)', '使用指南的繁體中文版。'],
      ['CONTRIBUTING.md', '贡献指南(英文)', '构建、测试、提交信息与发布流程。'],
      ['docs/architecture.md', '架构说明(英文)', '应用、Go 内核与原生服务如何配合。'],
    ],
  },
  {
    lang: 'zh-tw',
    page: 'zh-tw/docs/',
    title: '文件',
    intro: 'FlClash 的使用、建置與開發文件。',
    entries: [
      ['docs/user-guide.zh-TW.md', '使用指南', '新增伺服器、路由規則、DNS、虛擬網路卡、快捷鍵、備份與常見問題。'],
      ['docs/user-guide.zh-CN.md', '使用指南(简体中文)', '使用指南的簡體中文版。'],
      ['CONTRIBUTING.md', '貢獻指南(英文)', '建置、測試、提交資訊與發佈流程。'],
      ['docs/architecture.md', '架構說明(英文)', '應用、Go 核心與原生服務如何配合。'],
    ],
  },
];

// The site's home page has an English and a Simplified Chinese version; the
// Traditional Chinese pages send the reader to the Simplified one.
const LABELS = {
  en: { html: 'en', name: 'English', home: 'Home', docs: 'Documentation', github: 'GitHub', edit: 'Edit this page on GitHub', toc: 'On this page', theme: 'Toggle dark mode', root: '', docsRoot: 'docs/' },
  zh: { html: 'zh-CN', name: '简体中文', home: '首页', docs: '文档', github: 'GitHub', edit: '在 GitHub 上编辑此页', toc: '本页内容', theme: '切换深色模式', root: 'zh/', docsRoot: 'zh/docs/' },
  'zh-tw': { html: 'zh-TW', name: '繁體中文', home: '首頁', docs: '文件', github: 'GitHub', edit: '在 GitHub 上編輯此頁', toc: '本頁內容', theme: '切換深色模式', root: 'zh/', docsRoot: 'zh-tw/docs/' },
};

const escapeHtml = (text) =>
  text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

function slug(text) {
  return text
    .toLowerCase()
    .replace(/<[^>]*>/g, '')
    .replace(/[^\p{L}\p{N}\- ]/gu, '')
    .trim()
    .replace(/ /g, '-');
}

const depth = (page) => page.split('/').filter(Boolean).length;
const upFrom = (page) => '../'.repeat(depth(page));

// Where a link written in a document points on the built site.
function resolveLink(url, source, fromPage) {
  if (/^([a-z]+:|#)/i.test(url)) return url;
  const [path, anchor = ''] = url.split(/(?=#)/);
  const target = posix.normalize(posix.join(posix.dirname(source), path));
  const up = upFrom(fromPage);
  if (PAGE_OF.has(target)) return `${up}${PAGE_OF.get(target)}${anchor}`;
  if (target === 'README.md' || target === 'README_zh_CN.md' || target === 'README_zh_TW.md') {
    if (anchor === '#download' || anchor === '#下载' || anchor === '#下載') {
      return `${up}${target === 'README.md' ? '' : 'zh/'}#download`;
    }
    return `${REPO}/blob/main/${target}${anchor}`;
  }
  return `${REPO}/blob/main/${target}${anchor}`;
}

function inline(text, source, page) {
  const stash = [];
  const keep = (html) => `\u0000${stash.push(html) - 1}\u0000`;
  let s = text.replace(/`([^`]+)`/g, (_, code) => keep(`<code>${escapeHtml(code)}</code>`));
  s = s.replace(/<(https?:\/\/[^>\s]+)>/g, (_, url) => keep(`<a href="${escapeHtml(url)}">${escapeHtml(url)}</a>`));
  s = s.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (_, label, url) =>
    keep(`<a href="${escapeHtml(resolveLink(url, source, page))}">${escapeHtml(label)}</a>`),
  );
  s = escapeHtml(s);
  s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>').replace(/(^|[^*\w])\*([^*\n]+)\*(?!\w)/g, '$1<em>$2</em>');
  // A link label may hold a code span, so restore until nothing is left.
  while (s.includes('\u0000')) s = s.replace(/\u0000(\d+)\u0000/g, (_, index) => stash[Number(index)]);
  return s;
}

// A centred <picture> of the app, as the READMEs and guides open with. Its
// images are the snapshots the site build copies to the site's root; the
// light and dark ones are both written so the page's theme switch picks one.
function renderPicture(block, page) {
  const attr = (name) => block.match(new RegExp(`${name}="([^"]*)"`))?.[1] ?? '';
  const img = (path, theme) =>
    `<img class="${theme}" src="${escapeHtml(`${upFrom(page)}${posix.basename(path)}`)}" alt="${escapeHtml(attr('alt'))}" width="2400" height="1500" loading="lazy" decoding="async">`;
  const dark = attr('srcset');
  return `<figure class="shot">${img(attr('src'), 'light')}${dark ? img(dark, 'dark') : ''}</figure>`;
}

function renderTable(lines, source, page) {
  const cells = (line) => line.trim().replace(/^\||\|$/g, '').split('|').map((cell) => cell.trim());
  const head = cells(lines[0]);
  const body = lines.slice(2).map(cells);
  const row = (tag, items) => `<tr>${items.map((item) => `<${tag}>${inline(item, source, page)}</${tag}>`).join('')}</tr>`;
  return `<div class="table"><table><thead>${row('th', head)}</thead><tbody>${body.map((r) => row('td', r)).join('')}</tbody></table></div>`;
}

function renderMarkdown(markdown, source, page) {
  const lines = markdown.replace(/\r\n/g, '\n').split('\n');
  const html = [];
  const headings = [];
  let i = 0;
  const isBlock = (line) => /^(#{1,6}\s|```|\s*[-*]\s|\s*\d+\.\s|\|)/.test(line);
  while (i < lines.length) {
    const line = lines[i];
    if (!line.trim()) {
      i++;
    } else if (line.startsWith('<p align="center">')) {
      const block = [];
      while (i < lines.length && !lines[i].includes('</p>')) block.push(lines[i++]);
      block.push(lines[i++] ?? '');
      html.push(renderPicture(block.join('\n'), page));
    } else if (line.startsWith('```')) {
      const lang = line.slice(3).trim();
      const code = [];
      i++;
      while (i < lines.length && !lines[i].startsWith('```')) code.push(lines[i++]);
      if (i >= lines.length) throw new Error(`${source}: a code block is never closed`);
      i++;
      html.push(`<pre><code${lang ? ` class="language-${escapeHtml(lang)}"` : ''}>${escapeHtml(code.join('\n'))}</code></pre>`);
    } else if (/^#{1,6}\s/.test(line)) {
      const [, marks, text] = line.match(/^(#{1,6})\s+(.*)$/);
      const level = marks.length;
      const id = slug(text);
      if (level === 2) headings.push({ id, text: inline(text, source, page).replace(/<[^>]+>/g, '') });
      html.push(`<h${level} id="${id}">${inline(text, source, page)}</h${level}>`);
      i++;
    } else if (line.trim().startsWith('|') && /^\s*\|?\s*:?-{3,}/.test(lines[i + 1] || '')) {
      const table = [];
      while (i < lines.length && lines[i].trim().startsWith('|')) table.push(lines[i++]);
      html.push(renderTable(table, source, page));
    } else if (/^\s*([-*]|\d+\.)\s/.test(line)) {
      const ordered = /^\s*\d+\./.test(line);
      const items = [];
      while (i < lines.length && /^\s*([-*]|\d+\.)\s/.test(lines[i])) {
        let text = lines[i++].replace(/^\s*([-*]|\d+\.)\s+/, '');
        while (i < lines.length && lines[i].trim() && /^\s{2,}\S/.test(lines[i]) && !/^\s*([-*]|\d+\.)\s/.test(lines[i])) {
          text += ` ${lines[i++].trim()}`;
        }
        items.push(`<li>${inline(text, source, page)}</li>`);
      }
      html.push(`<${ordered ? 'ol' : 'ul'}>${items.join('')}</${ordered ? 'ol' : 'ul'}>`);
    } else {
      const paragraph = [];
      while (i < lines.length && lines[i].trim() && !(paragraph.length && isBlock(lines[i]))) paragraph.push(lines[i++].trim());
      html.push(`<p>${inline(paragraph.join(' '), source, page)}</p>`);
    }
  }
  return { html: html.join('\n'), headings };
}

const THEME_SCRIPT = `(function(){try{var t=localStorage.getItem('flclash.theme');if(t==='light'||t==='dark')document.documentElement.dataset.theme=t;}catch(e){}})();`;

// The switch flips the page away from the theme it shows, as the home page's does,
// and keeps the choice under the same key.
const TOGGLE_SCRIPT = `document.getElementById('theme-toggle').addEventListener('click',function(){var r=document.documentElement,c=r.dataset.theme||(matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light'),n=c==='dark'?'light':'dark';r.dataset.theme=n;try{localStorage.setItem('flclash.theme',n);}catch(e){}});`;

const THEME_ICON = `<svg class="theme-icon" viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><circle cx="12" cy="12" r="8.25" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M12 3.75a8.25 8.25 0 0 1 0 16.5Z" fill="currentColor"/></svg>`;

function layout({ page, lang, title, description, body, headings = [], source, alternates = [] }) {
  const up = upFrom(page);
  const L = LABELS[lang];
  const docsHome = `${up}${L.docsRoot}`;
  const toc = headings.length
    ? `<nav class="toc" aria-label="${escapeHtml(L.toc)}"><p>${escapeHtml(L.toc)}</p><ul>${headings.map((h) => `<li><a href="#${h.id}">${escapeHtml(h.text)}</a></li>`).join('')}</ul></nav>`
    : '';
  const hreflang = alternates.length
    ? [`\n  <link rel="alternate" hreflang="${L.html}" href="${siteUrl}${page}">`, ...alternates.map(({ page: alt, lang: other }) => `  <link rel="alternate" hreflang="${LABELS[other].html}" href="${siteUrl}${alt}">`)].join('\n')
    : '';
  const switcher = alternates
    .map(({ page: alt, lang: other }) => `<a class="lang" href="${up}${alt}" hreflang="${LABELS[other].html}" lang="${LABELS[other].html}">${escapeHtml(LABELS[other].name)}</a>`)
    .join('\n      ');
  const edit = source ? `<p class="edit"><a href="${REPO}/blob/main/${source}">${escapeHtml(L.edit)}</a></p>` : '';
  return `<!doctype html>
<html lang="${L.html}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <title>${escapeHtml(title)} – FlClash</title>
  <meta name="description" content="${escapeHtml(description)}">
  <meta name="color-scheme" content="light dark">
  <link rel="canonical" href="${siteUrl}${page}">${hreflang}
  <link rel="icon" href="${up}favicon.svg" type="image/svg+xml">
  <link rel="stylesheet" href="${up}assets/docs.css">
  <script>${THEME_SCRIPT}</script>
</head>
<body>
  <header class="bar">
    <a class="brand" href="${up}${L.root}"><img src="${up}icon.png" alt="" width="28" height="28"><span>FlClash</span></a>
    <nav>
      <a href="${up}${L.root}">${escapeHtml(L.home)}</a>
      <a href="${docsHome}">${escapeHtml(L.docs)}</a>
      <a href="${REPO}">${escapeHtml(L.github)}</a>
      ${switcher}
      <button class="theme" id="theme-toggle" type="button" aria-label="${escapeHtml(L.theme)}" title="${escapeHtml(L.theme)}">${THEME_ICON}</button>
    </nav>
  </header>
  <div class="layout">
    <main>
      <article class="doc">
${body}
      </article>
      ${edit}
    </main>
    ${toc}
  </div>
  <script>${TOGGLE_SCRIPT}</script>
</body>
</html>
`;
}

function write(page, html) {
  const dir = join(out, page);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, 'index.html'), html);
}

const pages = [];

for (const doc of DOCS) {
  const markdown = readFileSync(join(root, doc.source), 'utf8');
  const { html, headings } = renderMarkdown(markdown, doc.source, doc.page);
  const title = markdown.match(/^#\s+(.*)$/m)?.[1] ?? 'Documentation';
  const description = markdown.split('\n').find((line) => line.trim() && !line.startsWith('#') && !line.startsWith('**') && !line.startsWith('[')) ?? title;
  write(
    doc.page,
    layout({
      page: doc.page,
      lang: doc.lang,
      title,
      description: description.replace(/[`*[\]]/g, '').slice(0, 200),
      body: html,
      headings,
      source: doc.source,
      alternates: (doc.pairs ?? []).map((pair) => ({ page: PAGE_OF.get(pair), lang: DOCS.find((d) => d.source === pair).lang })),
    }),
  );
  pages.push(doc.page);
}

for (const index of INDEXES) {
  const body = [
    `<h1>${escapeHtml(index.title)}</h1>`,
    `<p>${escapeHtml(index.intro)}</p>`,
    `<ul class="cards">${index.entries
      .map(([source, name, text]) => `<li><a href="${upFrom(index.page)}${PAGE_OF.get(source)}"><strong>${escapeHtml(name)}</strong><span>${escapeHtml(text)}</span></a></li>`)
      .join('')}</ul>`,
  ].join('\n');
  write(index.page, layout({ page: index.page, lang: index.lang, title: index.title, description: index.intro, body }));
  pages.push(index.page);
}

const sitemapPath = join(out, 'sitemap.xml');
const sitemap = readFileSync(sitemapPath, 'utf8');
writeFileSync(
  sitemapPath,
  sitemap.replace('</urlset>', pages.map((page) => `  <url><loc>${siteUrl}${page}</loc></url>\n`).join('') + '</urlset>'),
);
