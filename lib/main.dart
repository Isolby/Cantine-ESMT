import 'package:flutter/material.dart';

void main() {
  runApp(CantineApp());
}

class CantineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cantine Université',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PageAccueil(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Page d'accueil pour choisir le mode
class PageAccueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cantine Université'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 100, color: Colors.blue),
            SizedBox(height: 40),
            Text(
              'Bienvenue',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InterfaceEtudiant()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: Text('Je suis Étudiant', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InterfaceGerant()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Colors.orange,
              ),
              child: Text('Je suis Gérant', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// Modèle pour un plat
class Plat {
  String nom;
  double prix;
  String image;

  Plat({required this.nom, required this.prix, required this.image});
}

// Modèle pour une commande
class Commande {
  String etudiant;
  List<Plat> plats;
  String etat; // "En attente", "Prêt", "Rupture"
  DateTime date;

  Commande({
    required this.etudiant,
    required this.plats,
    this.etat = "En attente",
    required this.date,
  });

  double get total {
    return plats.fold(0, (sum, plat) => sum + plat.prix);
  }
}

// Liste globale des plats disponibles
List<Plat> menuCantine = [
  Plat(nom: 'Riz au poulet', prix: 1500, image: '🍗'),
  Plat(nom: 'Thiéboudienne', prix: 2000, image: '🍲'),
  Plat(nom: 'Yassa poulet', prix: 1800, image: '🍖'),
  Plat(nom: 'Salade', prix: 500, image: '🥗'),
  Plat(nom: 'Sandwich', prix: 1000, image: '🥪'),
  Plat(nom: 'Jus', prix: 300, image: '🧃'),
];

// Liste globale des commandes
List<Commande> toutesLesCommandes = [];

// Interface Étudiant
class InterfaceEtudiant extends StatefulWidget {
  @override
  _InterfaceEtudiantState createState() => _InterfaceEtudiantState();
}

class _InterfaceEtudiantState extends State<InterfaceEtudiant> {
  List<Plat> panier = [];
  TextEditingController nomController = TextEditingController();

  void ajouterAuPanier(Plat plat) {
    setState(() {
      panier.add(plat);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${plat.nom} ajouté au panier')),
    );
  }

  void passerCommande() {
    if (nomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer votre nom')),
      );
      return;
    }

    if (panier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Votre panier est vide')),
      );
      return;
    }

    setState(() {
      toutesLesCommandes.add(Commande(
        etudiant: nomController.text,
        plats: List.from(panier),
        date: DateTime.now(),
      ));
      panier.clear();
      nomController.clear();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Succès'),
        content: Text('Votre commande a été passée avec succès !'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPanier = panier.fold(0, (sum, plat) => sum + plat.prix);

    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Étudiant'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
              if (panier.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${panier.length}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: nomController,
              decoration: InputDecoration(
                labelText: 'Votre nom',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Menu du jour',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: menuCantine.length,
              itemBuilder: (context, index) {
                Plat plat = menuCantine[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Text(plat.image, style: TextStyle(fontSize: 40)),
                    title: Text(plat.nom, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${plat.prix} FCFA'),
                    trailing: IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.green, size: 30),
                      onPressed: () => ajouterAuPanier(plat),
                    ),
                  ),
                );
              },
            ),
          ),
          if (panier.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('$totalPanier FCFA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: passerCommande,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Passer la commande', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Interface Gérant
class InterfaceGerant extends StatefulWidget {
  @override
  _InterfaceGerantState createState() => _InterfaceGerantState();
}

class _InterfaceGerantState extends State<InterfaceGerant> {
  void changerEtat(Commande commande, String nouvelEtat) {
    setState(() {
      commande.etat = nouvelEtat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Gérant'),
        backgroundColor: Colors.orange,
      ),
      body: toutesLesCommandes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Aucune commande pour le moment', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: toutesLesCommandes.length,
              itemBuilder: (context, index) {
                Commande commande = toutesLesCommandes[index];
                Color couleurEtat = commande.etat == "Prêt"
                    ? Colors.green
                    : commande.etat == "Rupture"
                        ? Colors.red
                        : Colors.orange;

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              commande.etudiant,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: couleurEtat,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                commande.etat,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Commande:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...commande.plats.map((plat) => Text('  • ${plat.nom} - ${plat.prix} FCFA')),
                        SizedBox(height: 8),
                        Text('Total: ${commande.total} FCFA', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => changerEtat(commande, "Prêt"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: Text('Prêt'),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => changerEtat(commande, "Rupture"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: Text('Rupture'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}