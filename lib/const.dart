import 'package:flutter/material.dart';

enum VariogramModel {
  spherical,
  exponential,
  gaussian,
  cubic,
}

const MAP_KEY = 'AIzaSyAql34T4IrMPnXk-19n-c-5uQ28DaUt8dM';
const kMainColor = Color.fromRGBO(48, 125, 126, 1);
//const kMainColor = Color.fromRGBO(47, 47, 47, 1);
const IS_TESTING = false;

String getModelName(VariogramModel model) {
  switch (model) {
    case VariogramModel.spherical:
      return 'Esférico';
    case VariogramModel.exponential:
      return 'Exponencial';
    case VariogramModel.gaussian:
      return 'Gaussiano';
    case VariogramModel.cubic:
      return 'Cúbico';
    default:
      return 'Esférico';
  }
}

VariogramModel getVariogramModel(String model) {
  if (model == 'spherical') {
    return VariogramModel.spherical;
  } else if (model == 'gaussian') {
    return VariogramModel.gaussian;
  } else if (model == 'exponential') {
    return VariogramModel.exponential;
  } else {
    return VariogramModel.spherical;
  }
}
