(() => {
  'use strict';

  const REPO = 'https://github.com/wyusgw/FlClash';
  const AUTO_DELAY = 400;

  const STRINGS = {
    en: {
      title: 'Download FlClash',
      looking: 'Looking for the right installer…',
      starting: (name) => `Your download of ${name} should start in a moment.`,
      ready: (name) => `The installer for ${name} is ready.`,
      button: (file) => `Download ${file}`,
      ios: 'FlClash is not available on iOS. Pick a build for another device below.',
      unknown: 'Pick the build for your system below.',
      failed: 'The list of files could not be loaded. Open the releases page instead.',
      releases: 'Open the releases page',
      all: 'All downloads',
      more: 'All platforms and the changelog',
    },
    zh: {
      title: '下载 FlClash',
      looking: '正在查找合适的安装包…',
      starting: (name) => `${name} 的下载即将开始。`,
      ready: (name) => `${name} 的安装包已就绪。`,
      button: (file) => `下载 ${file}`,
      ios: 'FlClash 暂不支持 iOS，请在下方选择其他设备的安装包。',
      unknown: '请在下方选择适合你系统的安装包。',
      failed: '无法加载文件列表，请改为打开发布页。',
      releases: '打开发布页',
      all: '全部下载',
      more: '全部平台与更新日志',
    },
  };

  const PLATFORM_NAMES = { android: 'Android', windows: 'Windows', macos: 'macOS', linux: 'Linux' };

  const params = new URLSearchParams(location.search);
  const lang = params.get('lang') === 'zh' || (params.get('lang') !== 'en' && /^zh/i.test(navigator.language || '')) ? 'zh' : 'en';
  const t = STRINGS[lang];
  const $ = (id) => document.getElementById(id);

  function goArch(arch) {
    return arch === 'arm64' ? 'arm64' : 'amd64';
  }

  // The file a visitor most likely wants, per system: the installer where there is one,
  // and the AppImage on Linux because it runs on every distribution.
  function primaryFor(platform, arch) {
    switch (platform) {
      case 'android':
        return 'android-arm64-v8a.apk';
      case 'windows':
        return `windows-${goArch(arch)}-setup.exe`;
      case 'macos':
        return arch === 'arm64' ? 'macos-arm64.dmg' : 'macos-amd64.dmg';
      case 'linux':
        return `linux-${goArch(arch)}.AppImage`;
      default:
        return null;
    }
  }

  function guessMacArch() {
    try {
      const gl = document.createElement('canvas').getContext('webgl');
      const info = gl && gl.getExtension('WEBGL_debug_renderer_info');
      const renderer = info ? gl.getParameter(info.UNMASKED_RENDERER_WEBGL) : '';
      if (/intel|amd|radeon|nvidia/i.test(renderer)) return 'x64';
    } catch {}
    return 'arm64';
  }

  async function detectDevice() {
    const ua = navigator.userAgent;
    const result = { platform: null, arch: null, ios: false };
    if (/android/i.test(ua)) result.platform = 'android';
    else if (/iphone|ipad|ipod/i.test(ua) || (/macintosh/i.test(ua) && navigator.maxTouchPoints > 1)) result.ios = true;
    else if (/windows/i.test(ua)) result.platform = 'windows';
    else if (/macintosh|mac os x/i.test(ua)) result.platform = 'macos';
    else if (/linux|x11|cros/i.test(ua)) result.platform = 'linux';
    if (/aarch64|arm64/i.test(ua)) result.arch = 'arm64';
    try {
      const hints = await navigator.userAgentData?.getHighEntropyValues(['architecture']);
      if (hints?.architecture === 'arm') result.arch = 'arm64';
      else if (hints?.architecture === 'x86') result.arch = 'x64';
    } catch {}
    if (result.platform === 'macos' && !result.arch) result.arch = guessMacArch();
    if (!result.arch) result.arch = 'x64';
    return result;
  }

  function sizeOf(bytes) {
    return bytes ? `${(bytes / 1048576).toFixed(1)} MB` : '';
  }

  function listAll(release) {
    const list = $('others-list');
    const files = [...release.assets.values()]
      .filter((asset) => /^FlClash-\d/.test(asset.name))
      .sort((a, b) => a.name.localeCompare(b.name));
    for (const asset of files) {
      const link = document.createElement('a');
      link.href = `${REPO}/releases/download/${release.tag}/${asset.name}`;
      link.textContent = asset.name.replace(`FlClash-${release.version}-`, '');
      const size = document.createElement('span');
      size.textContent = sizeOf(asset.size);
      link.append(size);
      const item = document.createElement('li');
      item.append(link);
      list.append(item);
    }
    $('others').hidden = false;
  }

  async function loadRelease() {
    const response = await fetch(new URL('../release.json', location.href), { cache: 'no-cache' });
    if (!response.ok) throw new Error(String(response.status));
    const data = await response.json();
    return {
      tag: data.tag,
      version: String(data.tag).replace(/^v/, ''),
      assets: new Map(data.assets.map((asset) => [asset.name, asset])),
    };
  }

  function showFailure() {
    $('status').textContent = t.failed;
    const button = $('primary');
    button.textContent = t.releases;
    button.hidden = false;
  }

  async function main() {
    document.documentElement.lang = lang === 'zh' ? 'zh-CN' : 'en';
    document.title = t.title;
    $('others-title').textContent = t.all;
    $('more').textContent = t.more;
    if (lang === 'zh') $('more').href = '../zh/';

    let release;
    try {
      release = await loadRelease();
    } catch {
      showFailure();
      return;
    }
    listAll(release);

    const device = await detectDevice();
    const id = device.ios ? null : primaryFor(device.platform, device.arch);
    const name = id ? `FlClash-${release.version}-${id}` : null;
    if (!name || !release.assets.has(name)) {
      $('status').textContent = device.ios ? t.ios : t.unknown;
      return;
    }

    const href = `${REPO}/releases/download/${release.tag}/${name}`;
    const auto = params.get('auto') !== '0';
    const button = $('primary');
    button.href = href;
    button.textContent = t.button(id);
    button.hidden = false;
    $('status').textContent = (auto ? t.starting : t.ready)(PLATFORM_NAMES[device.platform]);
    if (auto) setTimeout(() => location.assign(href), AUTO_DELAY);
  }

  main();
})();
