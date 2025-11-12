import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/pages/direcciones_page.dart';
import 'package:qr_reader/pages/mapa_page.dart';
import 'package:qr_reader/pages/otras_opciones_page.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';
import 'package:qr_reader/providers/ui_provider.dart';
import 'package:qr_reader/widgets/custom_navigatorbar.dart';
import 'package:qr_reader/widgets/scan_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        elevation: 0,
        title: Text('Historial'),

        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              Provider.of<ScanListProvider>(context, listen: false)
                .borrarTodos();
            },
          ),
        ],
      ),
      
      body: _HomePageBody(),

      bottomNavigationBar: CustomNavigatorbar(),

      floatingActionButton: ScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }
}

class _HomePageBody extends StatelessWidget {
  
  const _HomePageBody({super.key});

  @override
  Widget build(BuildContext context) {

    final uiProvider = Provider.of<UiProvider>(context);
    
    final currentIndex = uiProvider.selectedMenuOpt;

    switch( currentIndex ) {

      case 0:
        return MapaPage();

      case 1: 
        return DireccionesPage();

      case 2: 
        return OtraPage();

      default:
        return OtraPage();
    }


  }
}
