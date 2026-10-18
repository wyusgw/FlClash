import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/edit_server.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// A round flag for the country a node is in: the one the user placed it in,
/// else the one its name points at, else where its server is. A line of the
/// subscription's own notes borrows a real node's server, so it takes the
/// flag of [lead], the first real node, found the same way; the traffic line,
/// whose unit is the GB, takes the British one. Only what none of that places
/// falls back to the icon of what the notes tell, or the house.
class NodeIcon extends ConsumerWidget {
  const NodeIcon({
    super.key,
    required this.name,
    this.region,
    this.address,
    this.lead,
    this.size,
  });

  final String name;

  /// The country the user chose; null leaves it to the name.
  final String? region;

  /// Where the node points, `host:port`; a name with no country is looked up
  /// by it, while the user allows that.
  final String? address;

  /// The first node of the subscription that is not a line of its notes.
  final Proxy? lead;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = nodeInfoGlyph(name);
    final code = info == null
        ? _codeOf(ref, name, region, address)
        : region ?? infoFlagCode(ref, name, lead);
    return RegionFlag(code: code, size: size, fallback: info ?? AppGlyphs.home);
  }
}

String? _codeOf(WidgetRef ref, String name, String? region, String? address) {
  final code = region ?? nodeRegionCode(name);
  if (code != null) return code;
  final host = hostOfAddress(address);
  return host == null ? null : ref.watch(nodeGeoRegionProvider(host)).value;
}

/// The country a line of the subscription's notes is flagged with, ignoring
/// any the user chose for it: [infoLineRegionCode], and where that finds none,
/// where [lead]'s server is; null for a name that is no such line.
String? infoFlagCode(WidgetRef ref, String name, Proxy? lead) {
  if (nodeInfoGlyph(name) == null) return null;
  return infoLineRegionCode(name, lead) ??
      (lead == null
          ? null
          : _codeOf(ref, lead.name, lead.region, lead.address));
}

/// Opens the node for editing; a node the form cannot hold exactly has only
/// its name and server open to change, so that nothing else it carries is lost.
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
  if (outbound == null) {
    await BaseNavigator.push(context, _NodeDetailView(node: node));
    return;
  }
  final running = ref.read(currentProfileIdProvider) == profile.id
      ? ref.read(groupsProvider).getGroup(nodeGroupName)?.all
      : null;
  final lead = leadNode(
    running != null && running.isNotEmpty
        ? running
        : ref
              .read(profileNodesProvider(profile.id, profile.lastUpdateDate))
              .value,
  );
  final form = nodeFormOf(outbound);
  if (form == null) {
    await BaseNavigator.push(
      context,
      EditNodeEndpointView(profile: profile, outbound: outbound),
    );
    return;
  }
  await BaseNavigator.push(
    context,
    EditServerView(
      profile: profile,
      outbound: outbound,
      kind: form.kind,
      values: form.values,
      lead: lead,
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
