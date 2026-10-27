import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/stores.dart';
import '../models/commerce.dart';
import '../models/format.dart';
import '../models/shop_filters.dart';
import '../models/store.dart';
import '../state/app_scope.dart';
import '../theme.dart';
import 'basics.dart';

Future<T?> showKavoSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: KavoColors.ink.withValues(alpha: 0.45),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: builder(context),
    ),
  );
}

/// Standard sheet layout: title, scrollable body, optional pinned footer, and
/// room for the home indicator.
class KavoSheet extends StatelessWidget {
  const KavoSheet({super.key, required this.title, this.subtitle, required this.children, this.footer, this.trailing});

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 16;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.headlineSmall),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: context.text.bodyMedium),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 0, 20, footer == null ? bottom : 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
        if (footer != null)
          DecoratedBox(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: KavoColors.line))),
            child: Padding(padding: EdgeInsets.fromLTRB(20, 14, 20, bottom), child: footer),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: p.brandSoft, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: p.brand, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.bodySmall),
                Text(text, style: context.text.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _copy(BuildContext context, String text, String message) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  Navigator.of(context).pop();
  showSnack(context, message, icon: Icons.content_copy_rounded);
}

// --------------------------------------------------------------- notifications

class _InboxItem {
  const _InboxItem(this.icon, this.title, this.text, this.when, this.open);

  final IconData icon;
  final String title;
  final String text;
  final String when;
  final void Function(BuildContext context) open;
}

Future<void> showInboxSheet(BuildContext context, StoreKey store) {
  final account = context.readAccount;
  final shipped = account.orders.where((o) => o.status == OrderStatus.shipped).firstOrNull;
  final items = [
    if (shipped != null)
      _InboxItem(
        Icons.local_shipping_outlined,
        'Order ${shipped.id} is on the way',
        '${shipped.lines.first.product.name}${shipped.lines.length > 1 ? ' and ${plural(shipped.lines.length - 1, 'more item')}' : ''} '
            'arrives ${formatDay(shipped.eta)}.',
        '2h ago',
        (c) => c.push('/${store.name}/account/orders/${shipped.id}'),
      ),
    _InboxItem(
      Icons.sell_outlined,
      'DESK30: 30% off office desks',
      'The furniture flat sale on desks ends in three days.',
      'Yesterday',
      (c) => c.go('/furniture/shop?cat=Desks'),
    ),
    _InboxItem(
      Icons.eco_outlined,
      'Weekend discount on garden veg',
      'Fresh vegetables are on offer until Sunday night.',
      '2d ago',
      (c) => c.go('/grocery/shop?cat=Fresh%20Vegetables'),
    ),
  ];

  return showKavoSheet<void>(context, (sheet) {
    return KavoSheet(
      title: 'Notifications',
      subtitle: '${items.length} new this week',
      children: [
        for (final item in items)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(sheet).pop();
              item.open(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: sheet.palette.brandSoft, shape: BoxShape.circle),
                    child: Icon(item.icon, color: sheet.palette.brand, size: 21),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(item.title, style: sheet.text.titleSmall)),
                            Text(item.when, style: sheet.text.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(item.text, style: sheet.text.bodyMedium!.copyWith(fontSize: 13.5, height: 1.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  });
}

// --------------------------------------------------------------- store info

Future<void> showFlagshipSheet(BuildContext context) {
  return showKavoSheet<void>(context, (sheet) {
    return KavoSheet(
      title: 'Bellhaven Flagship',
      subtitle: 'Three floors of womenswear, menswear and accessories.',
      footer: FilledButton.icon(
        onPressed: () => _copy(sheet, Brand.address, 'Address copied'),
        icon: const Icon(Icons.content_copy_rounded, size: 19),
        label: const Text('Copy address'),
      ),
      children: [
        SizedBox(
          height: 170,
          child: KavoImage('assets/images/fa/promo-store.jpg', radius: BorderRadius.circular(18)),
        ),
        const SizedBox(height: 10),
        const _InfoRow(icon: Icons.place_outlined, title: 'Address', text: Brand.address),
        const _InfoRow(icon: Icons.schedule_rounded, title: 'Opening hours', text: Brand.hours),
        const _InfoRow(icon: Icons.call_outlined, title: 'Phone', text: Brand.phone),
      ],
    );
  });
}

Future<void> showHelpSheet(BuildContext context) {
  const faqs = [
    ('When will my order arrive?', 'Fashion ships the same working day, grocery arrives the same day when you order '
        'before 2pm, and furniture is made to order and delivered in four to six weeks.'),
    ('How do returns work?', 'Unused items go back within 30 days for a full refund, no questions. Start a return '
        'from the order page or call us.'),
    ('Is checkout secure?', 'Card details are tokenised by our payment provider and never touch Kavo’s servers.'),
  ];
  return showKavoSheet<void>(context, (sheet) {
    return KavoSheet(
      title: 'Help & support',
      subtitle: 'A person answers between 9 and 6, Monday to Saturday.',
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _copy(sheet, Brand.email, 'Email address copied'),
              child: const Text('Copy email'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () => _copy(sheet, Brand.phone, 'Phone number copied'),
              child: const Text('Copy phone'),
            ),
          ),
        ],
      ),
      children: [
        const _InfoRow(icon: Icons.call_outlined, title: 'Call us', text: Brand.phone),
        const _InfoRow(icon: Icons.mail_outline_rounded, title: 'Email', text: Brand.email),
        const SizedBox(height: 10),
        Text('Common questions', style: sheet.text.titleMedium),
        const SizedBox(height: 4),
        for (final (q, a) in faqs)
          ExpansionTile(
            title: Text(q, style: sheet.text.titleSmall),
            expandedAlignment: Alignment.centerLeft,
            children: [Text(a, style: sheet.text.bodyMedium)],
          ),
      ],
    );
  });
}

// --------------------------------------------------------------- account

Future<void> showAddressesSheet(BuildContext context) {
  return showKavoSheet<void>(context, (sheet) {
    final account = sheet.account;
    return KavoSheet(
      title: 'Saved addresses',
      subtitle: 'Your default is used at checkout.',
      footer: OutlinedButton.icon(
        onPressed: () async {
          final address = await showAddressForm(sheet);
          if (address != null && sheet.mounted) sheet.readAccount.addAddress(address);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add new address'),
      ),
      children: [
        for (final a in account.addresses) ...[
          SelectCard(
            selected: a.id == account.address.id,
            onTap: () => sheet.readAccount.selectAddress(a.id),
            child: AddressText(address: a),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  });
}

Future<void> showPaymentsSheet(BuildContext context) {
  return showKavoSheet<void>(context, (sheet) {
    final account = sheet.account;
    return KavoSheet(
      title: 'Payment methods',
      subtitle: 'Cards are tokenised and never stored on Kavo’s servers.',
      footer: OutlinedButton.icon(
        onPressed: () async {
          final card = await showCardForm(sheet);
          if (card != null && sheet.mounted) sheet.readAccount.addPayment(card);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add new card'),
      ),
      children: [
        for (final m in account.payments) ...[
          SelectCard(
            selected: m.id == account.payment.id,
            onTap: () => sheet.readAccount.selectPayment(m.id),
            child: PaymentText(method: m),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  });
}

Future<void> showNotificationPrefsSheet(BuildContext context) {
  return showKavoSheet<void>(context, (sheet) {
    final prefs = sheet.account.prefs;
    return KavoSheet(
      title: 'Notifications',
      subtitle: 'Choose what Kavo can tell you about.',
      children: [
        for (final entry in prefs.entries)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(entry.key, style: sheet.text.titleSmall),
            value: entry.value,
            onChanged: (v) => sheet.readAccount.setPref(entry.key, v),
          ),
      ],
    );
  });
}

/// Lets the account tab change storefront, which re-themes the whole app.
Future<void> showStorefrontSheet(BuildContext context, StoreKey current) {
  return showKavoSheet<void>(context, (sheet) {
    return KavoSheet(
      title: 'Storefront',
      subtitle: 'One app and one cart, three shops.',
      children: [
        for (final key in StoreKey.values) ...[
          SelectCard(
            selected: key == current,
            onTap: () {
              Navigator.of(sheet).pop();
              context.go('/${key.name}/account');
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(key.label, style: sheet.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(storeOf(key).tagline, style: sheet.text.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                PaletteSwatch(store: key),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  });
}

/// Three overlapping dots: a store's brand, dark and soft colours.
class PaletteSwatch extends StatelessWidget {
  const PaletteSwatch({super.key, required this.store});

  final StoreKey store;

  @override
  Widget build(BuildContext context) {
    final p = KavoPalette.of(store);
    final colors = [p.bar == Colors.white ? KavoColors.ink : p.bar, p.brand, p.brandSoft];
    return SizedBox(
      width: 58,
      height: 26,
      child: Stack(
        children: [
          for (var i = 0; i < colors.length; i++)
            Positioned(
              left: i * 16.0,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> showEditProfileSheet(BuildContext context) => showKavoSheet<void>(
  context,
  (_) => _ProfileForm(onSaved: () => showSnack(context, 'Profile updated', icon: Icons.check_circle_rounded)),
);

/// Address entry. Returns the new address, or null if dismissed.
Future<Address?> showAddressForm(BuildContext context) => showKavoSheet<Address>(context, (_) => const _AddressForm());

/// Card entry with light validation. Returns the tokenised card, or null.
Future<PaymentMethod?> showCardForm(BuildContext context) =>
    showKavoSheet<PaymentMethod>(context, (_) => const _CardForm());

String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
String? _validEmail(String? v) =>
    _required(v) ?? (RegExp(r'^\S+@\S+\.\S+$').hasMatch(v!.trim()) ? null : 'Enter a valid email');
String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

/// Gives a form sheet a [Form] key and text controllers that are disposed
/// with it.
mixin _FormSheetState<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  final _controllers = <TextEditingController>[];

  TextEditingController field([String text = '']) {
    final controller = TextEditingController(text: text);
    _controllers.add(controller);
    return controller;
  }

  bool get valid => formKey.currentState!.validate();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> with _FormSheetState {
  late final _profile = context.readAccount.profile;
  late final _name = field(_profile.name);
  late final _email = field(_profile.email);
  late final _phone = field(_profile.phone);

  void _save() {
    if (!valid) return;
    context.readAccount.updateProfile(
      _profile.copyWith(name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim()),
    );
    Navigator.of(context).pop();
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: KavoSheet(
        title: 'Edit profile',
        footer: FilledButton(onPressed: _save, child: const Text('Save changes')),
        children: [
          _Field(controller: _name, label: 'Full name', validator: _required),
          _Field(controller: _email, label: 'Email', keyboard: TextInputType.emailAddress, validator: _validEmail),
          _Field(controller: _phone, label: 'Phone', keyboard: TextInputType.phone, validator: _required),
        ],
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  const _AddressForm();

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> with _FormSheetState {
  late final _name = field(context.readAccount.profile.name);
  late final _line1 = field();
  late final _line2 = field();
  late final _city = field();
  late final _phone = field(context.readAccount.profile.phone);
  String _label = 'Home';

  void _save() {
    if (!valid) return;
    final line2 = _line2.text.trim();
    Navigator.of(context).pop(
      Address(
        id: 'addr-${DateTime.now().microsecondsSinceEpoch}',
        label: _label,
        name: _name.text.trim(),
        line1: _line1.text.trim(),
        line2: line2.isEmpty ? null : line2,
        city: _city.text.trim(),
        phone: _phone.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: KavoSheet(
        title: 'New address',
        footer: FilledButton(onPressed: _save, child: const Text('Save address')),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final l in ['Home', 'Work', 'Other'])
                ChoiceChip(label: Text(l), selected: l == _label, onSelected: (_) => setState(() => _label = l)),
            ],
          ),
          const SizedBox(height: 14),
          _Field(controller: _name, label: 'Full name', validator: _required),
          _Field(controller: _line1, label: 'Street address', hint: '24 Juniper Lane', validator: _required),
          _Field(controller: _line2, label: 'Apartment, floor (optional)'),
          _Field(controller: _city, label: 'City, state and ZIP', hint: 'Bellhaven, OR 97205', validator: _required),
          _Field(controller: _phone, label: 'Phone', keyboard: TextInputType.phone, validator: _required),
        ],
      ),
    );
  }
}

class _CardForm extends StatefulWidget {
  const _CardForm();

  @override
  State<_CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<_CardForm> with _FormSheetState {
  late final _number = field();
  late final _expiry = field();
  late final _cvc = field();
  late final _holder = field(context.readAccount.profile.name);

  void _save() {
    if (!valid) return;
    final n = _digits(_number.text);
    Navigator.of(context).pop(
      PaymentMethod(
        id: 'card-${DateTime.now().microsecondsSinceEpoch}',
        brand: n.startsWith('4') ? CardBrand.visa : CardBrand.mastercard,
        last4: n.substring(n.length - 4),
        expiry: _expiry.text,
        holder: _holder.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: KavoSheet(
        title: 'Add a card',
        subtitle: 'We accept Visa and Mastercard.',
        footer: FilledButton(onPressed: _save, child: const Text('Save card')),
        children: [
          _Field(
            controller: _number,
            label: 'Card number',
            hint: '4242 4242 4242 4242',
            keyboard: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (v) {
              final n = _digits(v ?? '');
              if (n.length != 16) return 'Enter the 16-digit card number';
              if (!n.startsWith('4') && !n.startsWith('5')) return 'Only Visa and Mastercard are accepted';
              return null;
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Field(
                  controller: _expiry,
                  label: 'Expiry',
                  hint: 'MM/YY',
                  keyboard: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  validator: (v) {
                    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(v ?? '');
                    final month = int.tryParse(m?.group(1) ?? '');
                    return month == null || month < 1 || month > 12 ? 'Use MM/YY' : null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                  controller: _cvc,
                  label: 'CVC',
                  hint: '123',
                  keyboard: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                  validator: (v) => (v ?? '').length == 3 ? null : '3 digits',
                ),
              ),
            ],
          ),
          _Field(controller: _holder, label: 'Name on card', validator: _required),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboard,
    this.formatters,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboard,
        inputFormatters: formatters,
        textInputAction: TextInputAction.next,
        style: context.text.bodyLarge,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final d = newValue.text;
    final out = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) out.write(' ');
      out.write(d[i]);
    }
    final s = out.toString();
    return TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final d = newValue.text;
    final s = d.length > 2 ? '${d.substring(0, 2)}/${d.substring(2)}' : d;
    return TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

// --------------------------------------------------------------- shared bits

class AddressText extends StatelessWidget {
  const AddressText({super.key, required this.address, this.showLabel = true});

  final Address address;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(child: Text(address.name, style: t.titleSmall!.copyWith(fontWeight: FontWeight.w600))),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: KavoColors.mist, borderRadius: BorderRadius.circular(99)),
                child: Text(address.label, style: t.labelSmall!.copyWith(color: KavoColors.ink, letterSpacing: 0.3)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          [address.line1, ?address.line2, address.city].join('\n'),
          style: t.bodyMedium!.copyWith(fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 2),
        Text(address.phone, style: t.bodySmall),
      ],
    );
  }
}

class PaymentText extends StatelessWidget {
  const PaymentText({super.key, required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CardBrandMark(brand: method.brand),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(method.title, style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
              Text(method.subtitle, style: context.text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple drawn card-network marks (no image assets needed).
class CardBrandMark extends StatelessWidget {
  const CardBrandMark({super.key, required this.brand, this.onDark = false});

  final CardBrand brand;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Widget mark = switch (brand) {
      CardBrand.visa => Text(
        'VISA',
        style: TextStyle(
          fontFamily: context.text.titleSmall!.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.6,
          color: onDark ? Colors.white : const Color(0xFF1A1F71),
        ),
      ),
      CardBrand.mastercard => SizedBox(
        width: 30,
        height: 18,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(color: Color(0xFFEB001B), shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
      CardBrand.cash => Icon(Icons.payments_outlined, size: 20, color: context.palette.brand),
    };
    if (onDark) return mark;
    return Container(
      width: 50,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KavoColors.line),
      ),
      child: mark,
    );
  }
}

// --------------------------------------------------------------- shop sort

Future<ShopSort?> showSortSheet(BuildContext context, ShopSort current) {
  return showKavoSheet<ShopSort>(context, (sheet) {
    return KavoSheet(
      title: 'Sort by',
      children: [
        for (final s in ShopSort.values)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              s.label,
              style: sheet.text.titleSmall!.copyWith(
                fontWeight: s == current ? FontWeight.w600 : FontWeight.w400,
                color: s == current ? sheet.palette.brandDark : KavoColors.ink,
              ),
            ),
            trailing: s == current ? Icon(Icons.check_rounded, color: sheet.palette.brand) : null,
            onTap: () => Navigator.of(sheet).pop(s),
          ),
      ],
    );
  });
}
