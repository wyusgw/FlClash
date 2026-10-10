import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_profiles.dart';

void main() {
  test('the setup state follows the profile and its last update', () {
    final updated = DateTime.utc(2026, 1, 2);
    final profile = Profile(
      id: 1,
      label: 'Home',
      autoUpdateDuration: Duration.zero,
      lastUpdateDate: updated,
    );
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(setupStateProvider(profile.id));

    expect(state.profileId, 1);
    expect(state.profileLastUpdateDate, updated.millisecondsSinceEpoch);
  });

  test('without a profile there is nothing to set up', () {
    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);

    final state = container.read(setupStateProvider(null));

    expect(state.profileId, isNull);
    expect(state.profileLastUpdateDate, isNull);
  });
}
