import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditItemWidget extends StatefulWidget {
  final String? icon;
  final String title;
  final VoidCallback? onTap;
  final Color? color;
  final Widget? parameter;
  final double textVerticalPading;
  const EditItemWidget({
    required this.title,
    this.icon,
    this.textVerticalPading = 20,
    this.onTap,
    this.parameter,
    this.color,
    super.key,
  });

  @override
  State<EditItemWidget> createState() => _EditItemWidgetState();
}

class _EditItemWidgetState extends State<EditItemWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.onTap != null) {
      return CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          widget.onTap?.call();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: widget.textVerticalPading),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            children: [
              if (widget.icon != null)
                const Padding(padding: EdgeInsets.only(left: 16, right: 12), child: Icon(Icons.timer_outlined)),
              if (widget.icon == null)
                const SizedBox(
                  width: 16,
                ),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.color ?? Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Padding(padding: const EdgeInsets.only(right: 18), child: widget.parameter ?? const SizedBox()),
            ],
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: widget.textVerticalPading),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            children: [
              if (widget.icon != null)
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 12),
                  child: Icon(Icons.timer_outlined),
                ),
              if (widget.icon == null)
                const SizedBox(
                  width: 16,
                ),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.color ?? Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.only(right: 18), child: widget.parameter ?? const SizedBox()),
            ],
          ),
        ),
      );
    }
  }
}
