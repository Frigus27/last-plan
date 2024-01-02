import 'package:flutter/material.dart';

class BoxedCard extends StatelessWidget {
  const BoxedCard(
      {super.key,
      this.widthFactor = 0.7,
      this.align = Alignment.topLeft,
      this.caption = '',
      this.style = null,
      this.captionAlign = TextAlign.left,
      this.child = const Placeholder(),
      this.padding = 20,
      this.useDivideLine = false,
      this.actions = const <Widget>[]});

  final String caption;
  final double widthFactor;
  final Alignment align;
  final TextAlign captionAlign;
  final TextStyle? style;
  final Widget child;
  final double padding;
  final bool useDivideLine;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle? the_style;
    if (style == null) {
      the_style = theme.textTheme.titleLarge;
    } else {
      the_style = style;
    }

    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: align,
                      child: Text(
                        caption,
                        style: the_style,
                        textAlign: captionAlign,
                      ),
                    ),
                  ),
                  for (var a in actions) a,
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              if (useDivideLine) const Divider(),
              if (useDivideLine)
                const SizedBox(
                  height: 20,
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class CaptionText extends StatelessWidget {
  const CaptionText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineLarge
        ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold);
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(20), child: Text(text, style: style)),
      ],
    );
  }
}

class SectionCaptionText extends StatelessWidget {
  const SectionCaptionText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineMedium?.copyWith(color: Colors.black);
    return Row(children: [
      Padding(
        padding: const EdgeInsets.all(40),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: style,
            textAlign: TextAlign.left,
          ),
        ),
      )
    ]);
  }
}

class PageCaption extends StatelessWidget {
  const PageCaption({super.key, this.caption = ''});

  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [CaptionText(text: caption)],
            )));
  }
}
