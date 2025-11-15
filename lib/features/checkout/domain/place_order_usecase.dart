import 'package:app/core/usecases/usecase.dart';
import 'package:app/features/cart/domain/models/cart_item_model.dart';
import 'package:app/features/checkout/domain/models/order_request_model.dart';
import 'package:app/features/checkout/domain/repository/order_repository.dart';

class OrderParams {
  final String billingFirstName;
  final String billingLastName;
  final String billingAddress1;
  final String billingCity;
  final String billingState;
  final String billingPostcode;
  final String billingCountry;
  final String billingEmail;
  final String billingPhone;
  final String shippingFirstName;
  final String shippingLastName;
  final String shippingAddress1;
  final String shippingCity;
  final String shippingState;
  final String shippingPostcode;
  final String shippingCountry;
  final List<CartItemModel> lineItems;
  final String paymentMethod;
  final String paymentMethodTitle;

  OrderParams({
    required this.billingFirstName,
    required this.billingLastName,
    required this.billingAddress1,
    required this.billingCity,
    required this.billingState,
    required this.billingPostcode,
    required this.billingCountry,
    required this.billingEmail,
    required this.billingPhone,
    required this.shippingFirstName,
    required this.shippingLastName,
    required this.shippingAddress1,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingPostcode,
    required this.shippingCountry,
    required this.lineItems,
    required this.paymentMethod,
    required this.paymentMethodTitle,
  });
}

class PlaceOrderUsecase extends UseCase<String, OrderParams> {
  final OrderRepository orderRepository;

  PlaceOrderUsecase({required this.orderRepository});

  @override
  Future<String> call(OrderParams paramas) async {
    return await orderRepository.createOrder(
      OrderRequestModel(
        currency: 'RON',
        paymentMethod: paramas.paymentMethod,
        paymentMethodTitle: paramas.paymentMethodTitle,
        setPaid: false,
        billing: Billing(
          firstName: paramas.billingFirstName,
          lastName: paramas.billingLastName,
          address1: paramas.billingAddress1,
          city: paramas.billingCity,
          state: paramas.billingState,
          postcode: paramas.billingPostcode,
          country: paramas.billingCountry,
          email: paramas.billingEmail,
          phone: paramas.billingPhone,
        ),
        shipping: Shipping(
          firstName: paramas.shippingFirstName,
          lastName: paramas.shippingLastName,
          address1: paramas.shippingAddress1,
          city: paramas.shippingCity,
          state: paramas.shippingState,
          postcode: paramas.shippingPostcode,
          country: paramas.shippingCountry,
        ),
        lineItems:
            paramas.lineItems
                .map(
                  (item) => LineItem(
                    productId: item.id,
                    quantity: item.quantity,
                  ),
                )
                .toList(),
        customerNote: '',
      ),
    );
  }
}
