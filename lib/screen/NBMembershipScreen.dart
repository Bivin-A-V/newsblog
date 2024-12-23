import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/main.dart';
import 'package:newsblog/model/NBModel.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBDataProviders.dart';
import 'package:newsblog/utils/NBWidgets.dart';

class NBMembershipScreen extends StatefulWidget {
  static String tag = '/NBMembershipScreen';

  @override
  NBMembershipScreenState createState() => NBMembershipScreenState();
}

class NBMembershipScreenState extends State<NBMembershipScreen> {
  List<NBMembershipPlanItemModel> membershipPlanList =
      nbGetMembershipPlanItems();
  int selectedIndex = 0;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    init();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> init() async {
    //
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle successful payment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment successful: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External wallet selected: ${response.walletName}")),
    );
  }

  void _startPayment(int amount) {
    var options = {
      'key': 'rzp_test_8u07b0KxxyLJZB', // Replace with your Razorpay API key
      'amount': amount * 100, // Convert amount to the smallest currency unit
      'name': 'NewsBlog Membership',
      'description': 'Membership Plan Payment',
      'prefill': {'contact': '7902282951', 'email': 'test@example.com'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: nbAppBarWidget(context, title: 'Membership'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            16.height,
            Text('Choose your plan', style: boldTextStyle(size: 20)),
            16.height,
            Text(
              'By becoming a member you can read on any\n device.read with no ads.and offline.',
              style: secondaryTextStyle(),
              textAlign: TextAlign.center,
            ),
            16.height,
            GridView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: membershipPlanList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 200,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(16),
                    backgroundColor:
                        appStore.isDarkModeOn ? cardDarkColor : white,
                    border: Border.all(
                        color: index == selectedIndex
                            ? NBPrimaryColor
                            : grey.withAlpha(51),
                        width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: index == selectedIndex
                              ? NBPrimaryColor
                              : grey.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check,
                            color: index == selectedIndex
                                ? white
                                : grey.withAlpha(51)),
                      ),
                      16.height,
                      Text('${membershipPlanList[index].timePeriod}',
                          style: boldTextStyle(size: 20)),
                      8.height,
                      Text('${membershipPlanList[index].price}',
                          style: boldTextStyle()),
                      16.height,
                      Text('${membershipPlanList[index].text}',
                          style: secondaryTextStyle()),
                    ],
                  ),
                ).onTap(
                  () {
                    setState(
                      () {
                        selectedIndex = index;
                      },
                    );
                  },
                );
              },
            ),
            16.height,
            nbAppButtonWidget(
              context,
              'Select Plan',
              () {
                // Get the amount based on the selected plan
                int amount = selectedIndex == 0
                    ? 499
                    : 299 * 12; // Monthly: Rs.499, Yearly: Rs.299 per month
                _startPayment(amount);
              },
            ),
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }
}
