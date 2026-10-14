import 'package:flutter/material.dart';

import '../about/app_info.dart';
import '../about/notices.dart';
import '../components/button.dart';
import '../components/pressable.dart';
import '../components/screen_header.dart';
import '../strings.dart';
import '../theme/colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({
    super.key,
    required this.onBack,
    required this.onOpenFreeSoftware,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenFreeSoftware;

  Widget _fact(BuildContext context, String label, String value) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return Semantics(
      container: true,
      label: '$label, $value',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: space3),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.line, width: borderWidth),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: Text(
                label,
                style: text.body.copyWith(color: colors.inkMuted),
              ),
            ),
            Expanded(child: Text(value, style: text.bodyStrong)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(space6, space5, space6, space6),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AltynemelButton(
            label: Strings.back,
            kind: ButtonKind.text,
            onPressed: onBack,
          ),
        ),
        const SizedBox(height: space3),
        const ScreenHeader(title: Strings.aboutApp),
        const SizedBox(height: space4),
        Text(Strings.aboutText, style: text.bodyLg),
        const SizedBox(height: space5),
        _fact(context, Strings.versionLabel, appVersion),
        _fact(context, Strings.licenseLabel, appLicense),
        const SizedBox(height: space3),
        Text(
          appCopyright,
          style: text.caption.copyWith(
            color: AltynemelColors.of(context).inkMuted,
          ),
        ),
        const SizedBox(height: space5),
        Pressable(
          onPressed: onOpenFreeSoftware,
          radius: radiusControl,
          semanticLabel: Strings.aboutFreeSoftware,
          builder: (context, state) {
            return Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.all(space3),
              decoration: BoxDecoration(
                color: state.hovered ? colors.surfaceHigh : Colors.transparent,
                borderRadius: borderRadiusControl,
                border: Border.all(
                  color: colors.lineStrong,
                  width: borderWidth,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Strings.aboutFreeSoftware, style: text.bodyStrong),
                  Text(
                    Strings.aboutFreeSoftwareHint,
                    style: text.caption.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class FreeSoftwareScreen extends StatefulWidget {
  const FreeSoftwareScreen({super.key, required this.onBack, this.load});

  final VoidCallback onBack;
  final Future<Notices> Function()? load;

  @override
  State<FreeSoftwareScreen> createState() => _FreeSoftwareScreenState();
}

class _FreeSoftwareScreenState extends State<FreeSoftwareScreen> {
  late final Future<Notices> _notices = (widget.load ?? loadNotices)();

  @override
  Widget build(BuildContext context) {
    final colors = AltynemelColors.of(context);
    final text = AltynemelTextStyles.of(context);
    return FutureBuilder<Notices>(
      future: _notices,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final sections = data?.sections ?? const <NoticeSection>[];
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                space6,
                space5,
                space6,
                space4,
              ),
              sliver: SliverList.list(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AltynemelButton(
                      label: Strings.back,
                      kind: ButtonKind.text,
                      onPressed: widget.onBack,
                    ),
                  ),
                  const SizedBox(height: space3),
                  ScreenHeader(
                    title: Strings.aboutFreeSoftware,
                    caption: data == null
                        ? null
                        : Strings.licenseCount(sections.length),
                  ),
                  const SizedBox(height: space4),
                  Text(Strings.freeSoftwareIntro, style: text.bodyLg),
                  const SizedBox(height: space4),
                  if (snapshot.hasError)
                    Text(
                      Strings.licensesFailed,
                      style: text.body.copyWith(color: colors.alert),
                    )
                  else if (data == null)
                    Text(
                      Strings.loadingLicenses,
                      style: text.body.copyWith(color: colors.inkMuted),
                    )
                  else
                    SelectableText(data.notice, style: text.body),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(space6, 0, space6, space6),
              sliver: SliverList.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: space4),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: colors.line, width: borderWidth),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(section.title, style: text.bodyStrong),
                        ),
                        for (final body in section.texts) ...[
                          const SizedBox(height: space3),
                          SelectableText(
                            body,
                            style: text.caption.copyWith(
                              color: colors.inkMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
