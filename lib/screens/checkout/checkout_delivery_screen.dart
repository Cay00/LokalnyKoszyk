import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/supabase/profile_write.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/presentation/checkout_bloc.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/app_text_field.dart';
import 'package:lokalny_koszyk/widgets/common/app_toggle_row.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutDeliveryScreen extends StatefulWidget {
  const CheckoutDeliveryScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<CheckoutDeliveryScreen> createState() => _CheckoutDeliveryScreenState();
}

class _CheckoutDeliveryScreenState extends State<CheckoutDeliveryScreen> {
  final _newAddressController = TextEditingController();
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  @override
  void dispose() {
    _newAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultAddress() async {
    final user = supabase.auth.currentUser;
    String address = '';
    if (user != null) {
      final meta = user.userMetadata?['default_address'];
      if (meta is String) address = meta.trim();
      try {
        final row = await supabase
            .from('profiles')
            .select('default_address')
            .eq('id', user.id)
            .maybeSingle();
        final fromRow = (row?['default_address'] ?? '').toString().trim();
        if (fromRow.isNotEmpty) address = fromRow;
      } catch (_) {}
    }
    if (!mounted) return;
    context.read<CheckoutBloc>().add(CheckoutDefaultAddressLoaded(address));
    setState(() => _loadingAddress = false);
  }

  Future<void> _confirm() async {
    final bloc = context.read<CheckoutBloc>();
    final state = bloc.state;

    if (state.deliveryOption != DeliveryOption.personalPickup &&
        !state.canConfirmAddress) {
      showAppNotification(
        context,
        state.addressChoice == CheckoutAddressChoice.current
            ? 'Brak zapisanego adresu. Dodaj nowy adres dostawy.'
            : 'Podaj adres dostawy.',
      );
      return;
    }

    if (state.addressChoice == CheckoutAddressChoice.newAddress &&
        state.newAddress.trim().isNotEmpty) {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final address = state.newAddress.trim();
        try {
          final meta = Map<String, dynamic>.from(
            user.userMetadata ?? <String, dynamic>{},
          );
          meta['default_address'] = address;
          await supabase.auth.updateUser(UserAttributes(data: meta));
          try {
            await syncOwnProfileRow(
              userId: user.id,
              fields: <String, dynamic>{'default_address': address},
            );
          } catch (_) {}
        } catch (_) {}
      }
    }

    bloc.add(const CheckoutPayRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (CheckoutState previous, CheckoutState current) =>
          current.feedbackMessage != null &&
          current.feedbackMessage != previous.feedbackMessage,
      listener: (BuildContext context, CheckoutState state) {
        final message = state.feedbackMessage;
        if (message == null) return;
        showAppNotification(context, message);
        if (message.contains('złożone')) {
          Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
        }
      },
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (BuildContext context, CheckoutState state) {
        final needsAddress =
            state.deliveryOption != DeliveryOption.personalPickup;

        return DefaultScreen(
          title: 'Adres dostawy',
          onBack: widget.onBack,
          showBottomNavPadding: false,
          body: _loadingAddress
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: <Widget>[
                          if (!needsAddress) ...[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.normal,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Wybrałeś odbiór osobisty — adres dostawy nie jest wymagany.',
                                  style: AppTypography.normal,
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Gdzie dostarczyć zamówienie?',
                              style: AppTypography.header,
                            ),
                            const SizedBox(height: 12),
                            AppSelectTile<CheckoutAddressChoice>(
                              value: CheckoutAddressChoice.current,
                              groupValue: state.addressChoice,
                              label: 'Aktualny adres',
                              subtitle: state.defaultAddress.isEmpty
                                  ? 'Brak zapisanego adresu domyślnego'
                                  : state.defaultAddress,
                              onChanged: (CheckoutAddressChoice value) {
                                context.read<CheckoutBloc>().add(
                                  CheckoutAddressChoiceChanged(value),
                                );
                              },
                            ),
                            AppSelectTile<CheckoutAddressChoice>(
                              value: CheckoutAddressChoice.newAddress,
                              groupValue: state.addressChoice,
                              label: 'Dodaj nowy adres',
                              onChanged: (CheckoutAddressChoice value) {
                                context.read<CheckoutBloc>().add(
                                  CheckoutAddressChoiceChanged(value),
                                );
                              },
                            ),
                            if (state.addressChoice ==
                                CheckoutAddressChoice.newAddress) ...[
                              const SizedBox(height: 8),
                              AppTextField(
                                controller: _newAddressController,
                                label: 'Nowy adres dostawy',
                                hint: 'ulica, numer, kod, miasto',
                                maxLines: 3,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (String value) {
                                  context.read<CheckoutBloc>().add(
                                    CheckoutNewAddressChanged(value),
                                  );
                                },
                              ),
                            ],
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Do zapłaty',
                                  style: AppTypography.normal,
                                ),
                              ),
                              Text(
                                '${state.productsTotal.toStringAsFixed(2).replaceAll('.', ',')} zł',
                                style: AppTypography.header,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: PrimaryActionButton(
                          label: state.isPaying
                              ? 'Składanie…'
                              : 'Potwierdź zamówienie',
                          onPressed: state.isPaying ? null : _confirm,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    ),
    );
  }
}
