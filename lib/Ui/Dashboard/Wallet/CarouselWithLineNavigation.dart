import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';

class CarouselWithLineNavigation extends StatefulWidget {
  @override
  _CarouselWithLineNavigationState createState() =>
      _CarouselWithLineNavigationState();
}

class _CarouselWithLineNavigationState
    extends State<CarouselWithLineNavigation> {
  int _currentIndex = 0;
  bool adsVisibility = true;
  late Map<int, String> info = {
    0: "Trade crypto anytime, anywhere. Buy and sell on the go!",
    1: "Earn 30% affiliate commission on every crypto exchange you make!",
    2: "Sell crypto and get paid instantly—quick and easy!",
    3: "Buy and sell Perfect Money, Payeer, and WebMoney all in one place.",
    4: "Sell PM and Bitcoin on the go—fast and hassle-free!"
  };

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: adsVisibility,
        child: Column(
          children: [
            Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: 5,
                  itemBuilder: (context, index, realIndex) {
                    return Container(
                      margin: EdgeInsets.only(top: 22, left: 24, right: 24),
                      padding: EdgeInsets.all(8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: NewColor.dashboardPrimaryColor,
                      ),
                      child:
                      Row(
                        children: [
                          // Image
                          Image.asset(
                            "assets/images/dashboard/mine.png",
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 10), // Adjusted spacing
                          // Column with text and link
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  info[index]!,
                                  style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(height: 5),
                                InkWell(
                                  onTap: () {
                                    // Handle button press
                                  },
                                  child: Text(
                                    "Learn more",
                                    style: NewStyle.tx14SplashWhite.copyWith(
                                        fontSize: 10,
                                        color: NewColor.btnBgGreenColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          InkWell(
                            onTap: () {
                              setState(() {
                                adsVisibility = false;
                              });
                            },
                            child: Image.asset(
                              "assets/images/dashboard/cancel.png",
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 100,
                    viewportFraction: 1.0,
                    initialPage: 0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    autoPlay: true, // Enables automatic sliding
                    autoPlayInterval: Duration(seconds: 4), // Duration between slides
                    autoPlayAnimationDuration: Duration(milliseconds: 800), // Animation duration
                    autoPlayCurve: Curves.fastOutSlowIn,
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.4 -
                      50, // Distance from the left
                  bottom: 10, // Distance from the bottom
                  child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width *
                        0.5, // Adjust width as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 3.5),
                          height: 1,
                          width: 14,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? MyColor.mainWhiteColor
                                : Color(0xFF646565),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
