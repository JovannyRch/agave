import 'package:agave/backend/models/calculos.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/const.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:flutter/material.dart';

class CalculosBottomSheet extends StatefulWidget {
  List<Incidencia> incidencias = [];

  CalculosBottomSheet({super.key, required this.incidencias});

  @override
  State<CalculosBottomSheet> createState() => _CalculosBottomSheetState();
}

class _CalculosBottomSheetState extends State<CalculosBottomSheet> {
  bool isLoading = true;
  CalculoResultado resultado = CalculoResultado(
    media: 0,
    varianza: 0,
    desviacionEstandar: 0,
    totalMuestreos: 0,
    totalIncidencias: 0,
  );

  @override
  void initState() {
    calculate();
    super.initState();
  }

  void calculate() async {
    setState(() {
      isLoading = true;
    });
    resultado = await Calculo(incidencias: widget.incidencias).calcular();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: const Center(
              child: CircularProgressIndicator(
                color: kMainColor,
              ),
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height * 0.45,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: Column(
              children: [
                const Text(
                  "Calculos",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CardDetail(
                              title: "Total muestreos",
                              value: resultado.totalMuestreos.toString(),
                              color: Colors.transparent,
                              isCenter: true,
                            ),
                          ),
                          Expanded(
                            child: CardDetail(
                              title: "Total incidencias",
                              value: resultado.totalIncidencias.toString(),
                              color: Colors.transparent,
                              isCenter: true,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CardDetail(
                              title: "Media",
                              value: resultado.media.toStringAsFixed(2),
                              color: Colors.transparent,
                              isCenter: true,
                            ),
                          ),
                          Expanded(
                            child: CardDetail(
                              title: "Varianza",
                              value: resultado.varianza.toStringAsFixed(2),
                              color: Colors.transparent,
                              isCenter: true,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CardDetail(
                              title: "Desviación estandar",
                              value: resultado.desviacionEstandar
                                  .toStringAsFixed(2),
                              color: Colors.transparent,
                              isCenter: true,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
