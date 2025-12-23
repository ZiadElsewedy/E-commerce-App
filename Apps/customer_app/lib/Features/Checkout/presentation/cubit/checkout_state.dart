/// Checkout State - Presentation Layer
/// حالة الدفع في طبقة العرض
class CheckoutState {
  final String name;
  final String phone;
  final String city;
  final String street;
  final String? notes;
  final bool isLoading;
  final String? errorMessage;

  const CheckoutState({
    this.name = '',
    this.phone = '',
    this.city = '',
    this.street = '',
    this.notes,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isValid =>
      name.isNotEmpty && phone.isNotEmpty && city.isNotEmpty && street.isNotEmpty;

  CheckoutState copyWith({
    String? name,
    String? phone,
    String? city,
    String? street,
    String? notes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CheckoutState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      street: street ?? this.street,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

