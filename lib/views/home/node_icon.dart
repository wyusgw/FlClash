import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/views/profiles/edit_server.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// A round flag for the country a node is in: the one the user placed it in,
/// else the one its name points at. Without one, or with one the flag set
/// lacks, a line of the subscription's own notes gets the icon of what it
/// tells, and any other name the plain house badge.
class NodeIcon extends ConsumerWidget {
  const NodeIcon({
    super.key,
    required this.name,
    this.region,
    this.address,
    this.size,
  });

  final String name;

  /// The country the user chose; null leaves it to the name.
  final String? region;

  /// Where the node points, `host:port`; a name with no country is looked up
  /// by it, while the user allows that.
  final String? address;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var code = region ?? nodeRegionCode(name);
    final host = hostOfAddress(address);
    if (code == null && host != null) {
      code = ref.watch(nodeGeoRegionProvider(host)).value;
    }
    return RegionFlag(
      code: code,
      size: size,
      fallback: nodeInfoGlyph(name) ?? AppGlyphs.home,
    );
  }
}

/// Opens the node for editing; a node the form cannot hold exactly is only
/// shown, so that nothing it carries is lost.
Future<void> showNodeDetail(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
  Proxy node,
) async {
  final outbound = await ref
      .read(profilesActionProvider.notifier)
      .readNodeOutbound(profile, node.name);
  if (!context.mounted) return;
  final form = outbound == null ? null : nodeFormOf(outbound);
  if (outbound == null || form == null) {
    await BaseNavigator.push(context, _NodeDetailView(node: node));
    return;
  }
  await BaseNavigator.push(
    context,
    EditServerView(
      profile: profile,
      outbound: outbound,
      kind: form.kind,
      values: form.values,
    ),
  );
}

class _NodeDetailView extends StatelessWidget {
  const _NodeDetailView({required this.node});

  final Proxy node;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: node.name,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          GroupedSection(
            children: [
              GroupedRow(title: appLocalizations.name, value: node.name),
              GroupedRow(title: 'Type', value: node.type.toUpperCase()),
              if (node.network != null)
                GroupedRow(
                  title: appLocalizations.network,
                  value: node.network!.toUpperCase(),
                ),
              if (node.address != null)
                GroupedRow(
                  title: appLocalizations.address,
                  value: node.address,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
