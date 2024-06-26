import 'dart:async';
import 'dart:math';
import 'package:demineur/controllers/session_controller.dart';
import 'package:get/get.dart';
import 'package:demineur/models/case.dart';

class Grid {
  int _row;

  int get row => _row;

  set row(int value) {
    _row = value;
  }

  int _col;

  int get col => _col;

  set col(int value) {
    _col = value;
  }

  int _minesNumber;

  int get minesNumber => _minesNumber;

  set minesNumber(int value) {
    _minesNumber = value;
  }

  int unCoverCells = 0;
  int cellsWMine = 0;
  List<CaseModel> cases = [];
  bool hasFirstTouch = false;

  SessionController sessionController = Get.put(SessionController());

  Grid(this._col, this._row, this._minesNumber);

  //case list creation
  void Casecreation() {
    int caseNumbers = col * row;
    cellsWMine = (caseNumbers - minesNumber);
    for (int j = 0; j < caseNumbers; j++) {
      int x = j % col;
      int y = j ~/ col;
      cases.add(CaseModel(false, j, x, y, false, false, this));
    }
    //return cases;
  }

//Case list update with random mined cases
  void MineCases(List<int> firstTouchIds) {
    int caseNumbers = col * row;
    List<int> minedIndex = [];
    int i = 0, j = 0;
    //iteration to create number of mines at random positions
    for (i = 0; i < minesNumber; i++) {
      int id = Random().nextInt(caseNumbers);
      if (!firstTouchIds.contains(id) && !minedIndex.contains(id)) {
        minedIndex.add(id);
      } else {
        int id = Random().nextInt(caseNumbers);
        minedIndex.add(id);
      }
    }
    //iteration to add mine to cases
    for (j = 0; j < minedIndex.length; j++) {
      //verified if the index is among mined indexes
      //and set the case as mined
      this.cases[minedIndex[j]].isMined = true;
    }
  }

  // get index of a cell based on its position
  int indexFromPosition(int x, int y) {
    int id = cases.indexWhere((element) => element.x == x && element.y == y);
    return id;
  }

  //check if the index returned exist and return a list
  // of existing index
  List<int> checkId(List<int> nbl, int i) {
    if (i > -1) {
      nbl.add(i);
    }
    return nbl;
  }

  //Get nearby cells positions of a specific cell
  List<int> nearbyCases(int x, int y) {
    List<int> nearbyList = [];
    int leftid = indexFromPosition((x - 1), y);
    checkId(nearbyList, leftid);
    int rightid = indexFromPosition((x + 1), y);
    checkId(nearbyList, rightid);
    int bottomLid = indexFromPosition((x - 1), (y - 1));
    checkId(nearbyList, bottomLid);
    int bottomRid = indexFromPosition((x + 1), (y - 1));
    checkId(nearbyList, bottomRid);
    int bottom = indexFromPosition(x, (y - 1));
    checkId(nearbyList, bottom);
    int topLid = indexFromPosition((x - 1), (y + 1));
    checkId(nearbyList, topLid);
    int topid = indexFromPosition(x, (y + 1));
    checkId(nearbyList, topid);
    int topRid = indexFromPosition((x + 1), (y + 1));
    checkId(nearbyList, topRid);
    return nearbyList;
  }

  // count nearby mines of a specific cell
  int nearbyMines(int x, int y) {
    int numberofM = 0;
    List<int> nearbyList = nearbyCases(x, y);
    for (int i = 0; i < nearbyList.length; i++) {
      if (cases[nearbyList[i]].isMined) {
        numberofM += 1;
      }
    }
    return numberofM;
  }

  //change of the uncover state of a specific cell
  void uncovercase(CaseModel ca) {
    cases[ca.index].unCovered = true;
  }

  //first touch uncover function
  void firstTouch(List<int> nearByCases, int cellTouchedId) {
    List<int> firstTouchIds = nearByCases;
    firstTouchIds.add(cellTouchedId);
    MineCases(firstTouchIds);
    for (int i = 0; i < nearByCases.length; i++) {
      unCoverCases(cases[nearByCases[i]]);
    }
  }

  void afterFirstTouch(CaseModel caseModel) {
    int nByMines = nearbyMines(caseModel.x, caseModel.y);
    // in case nearby mine equal zero
    if (nByMines == 0 && !caseModel.isMined) {
      uncovercase(caseModel);
      caseModel.grid.unCoverCells += 1;
      if (this.unCoverCells == this.cellsWMine) {
        sessionController.updateWinState(true);
      }
      List<int> nearByCases = nearbyCases(caseModel.x, caseModel.y);
      for (int i = 0; i < nearByCases.length; i++) {
        unCoverCases(cases[nearByCases[i]]);
      }
    } else if (nByMines > 0 && !caseModel.isMined) {
      // in case nearby mine is greater than 0
      cases[caseModel.index].nearbyMine = nByMines.toString();
      caseModel.grid.unCoverCells += 1;
      uncovercase(caseModel);
    }
  }

  Future unCoverMines() async {
    for (int i = 0; i < cases.length; i++) {
      if (cases[i].isMined) uncovercase(cases[i]);
    }
  }

  // recurcive function to uncover a cell and adjacent cells
  void unCoverCases(CaseModel caseModel) {
    int x = caseModel.x;
    int y = caseModel.y;
    //check if cell is uncovered
    if (!caseModel.unCovered) {
      if (!sessionController.session.flagSelected && !caseModel.isFlaged) {
        //in case one cell has been touched already
        if (hasFirstTouch) {
          //afterFirstTouch(caseModel);
          int nByMines = nearbyMines(x, y);
          // in case nearby mine equal zero
          if (nByMines == 0 && !caseModel.isMined) {
            uncovercase(caseModel);
            caseModel.grid.unCoverCells += 1;
            if (this.unCoverCells == this.cellsWMine) {
              sessionController.updateWinState(true);
            }
            List<int> nearByCases = nearbyCases(x, y);
            for (int i = 0; i < nearByCases.length; i++) {
              unCoverCases(cases[nearByCases[i]]);
            }
          } else if (nByMines > 0 && !caseModel.isMined) {
            // in case nearby mine is greater than 0
            cases[caseModel.index].nearbyMine = nByMines.toString();
            caseModel.grid.unCoverCells += 1;
            uncovercase(caseModel);
          }
        } else if (!hasFirstTouch) {
          //in case of first touch
          sessionController.updateTimer();
          List<int> nearByCases = nearbyCases(x, y);
          hasFirstTouch = true;
          firstTouch(nearByCases, caseModel.index);
        }
      } else if (sessionController.session.flagSelected) {
        //in case session flag is selected
        caseModel.isFlaged = true;
        minesNumber -= 1;
        sessionController.updateFlagState(false);
      } else if (caseModel.isFlaged) {
        // case cell is flagged
        caseModel.isFlaged = false;
        minesNumber += 1;
      }
    }
  }
}
