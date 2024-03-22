import 'package:demineur/models/case.dart';
import 'package:demineur/models/grid.dart';
import 'package:demineur/models/session.dart';
import 'package:demineur/utils/colors.dart';
import 'package:get/get.dart';
import 'package:demineur/views/widgets/bottom_rounded.dart';
import 'package:demineur/views/widgets/casewidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Grid grid = Grid(10, 10);

  GridController gridController = Get.put(GridController());
  @override
  Widget build(BuildContext context) {
    List<CaseModel> listCases = grid.Casecreation();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: BaseColors.primaryColor1,
        child: SafeArea(
          child: Stack(
            children: [
              Image.asset(
                "assets/images/logo.png",
              ),
              Positioned(
                  top: (height * 0.25),
                  child: Container(
                    width: width - 20,
                    height: height * 0.5,
                    margin: EdgeInsets.all(10),
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 10),
                        itemCount: 100,
                        itemBuilder: (BuildContext context, int index) {
                          gridController.addCase(listCases[index]);
                          return Obx(() => Casewidget(
                                caseModel:
                                    gridController.casesController[index],
                              ));
                        }),
                  )),
              Positioned(
                  top: height * 0.75,
                  child: SizedBox(
                    height: 70,
                    width: width,
                    child: Center(
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(180)),
                        child: SvgPicture.asset(
                          "assets/images/flagad.svg",
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  )),
              BottomRoundedRow(
                width: width,
                LeftIcon: Icons.home,
                ontapLeft: () {
                  Navigator.pop(context);
                },
                rightIcon: Icons.replay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
