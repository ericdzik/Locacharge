import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:locacharge/shared/styles/colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Comment fonctionne LocaCharge ?',
      answer:
          'LocaCharge vous aide à trouver les points de recharge téléphonique et services numériques les plus proches de vous. Utilisez la carte interactive pour localiser les commerçants, consultez leurs disponibilités en temps réel et obtenez des itinéraires.',
    ),
    FAQItem(
      question: 'Comment ajouter un commerçant à mes favoris ?',
      answer:
          'Sur la fiche d\'un commerçant, appuyez sur l\'icône cœur pour l\'ajouter à vos favoris. Vous pourrez ensuite le retrouver facilement dans l\'onglet "Favoris" de l\'historique.',
    ),
    FAQItem(
      question: 'Les informations de disponibilité sont-elles fiables ?',
      answer:
          'Nous nous efforçons de maintenir des informations à jour, mais la disponibilité peut varier rapidement. Nous recommandons de contacter le commerçant directement avant de vous déplacer.',
    ),
    FAQItem(
      question: 'Comment signaler une erreur ou un commerçant fermé ?',
      answer:
          'Vous pouvez signaler un problème en utilisant le bouton "Signaler" sur la fiche du commerçant ou en nous contactant directement via l\'onglet "Contact" de cette page d\'aide.',
    ),
    FAQItem(
      question: 'L\'application fonctionne-t-elle hors ligne ?',
      answer:
          'LocaCharge nécessite une connexion internet pour afficher la carte et les informations en temps réel. Cependant, vos favoris et votre historique sont sauvegardés localement.',
    ),
    FAQItem(
      question: 'Comment devenir partenaire LocaCharge ?',
      answer:
          'Si vous êtes commerçant et souhaitez apparaître sur LocaCharge, contactez-nous via l\'onglet "Contact" ou envoyez-nous un email à partenaires@locacharge.ci',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Aide'),
        backgroundColor: AppColors.surfaceColor,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Bienvenue
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline,
                            color: AppColors.primaryColor, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bienvenue sur LocaCharge !',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Trouvez rapidement les points de recharge et services numériques près de chez vous. Cette page vous aide à utiliser l\'application efficacement.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section Guide rapide
            Text(
              'Guide rapide',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildQuickGuide(),
            const SizedBox(height: 24),

            // Section FAQ
            _buildSection(
              title: 'Questions fréquentes',
              icon: Icons.help_outline,
              children: [
                _buildFAQItem(
                  question: 'Comment fonctionne LocaCharge ?',
                  answer:
                      'LocaCharge vous aide à trouver des points de recharge téléphonique et des services numériques près de chez vous. Utilisez la carte ou la recherche pour localiser les commerçants.',
                ),
                _buildFAQItem(
                  question: 'Comment ajouter un commerçant ?',
                  answer:
                      'Pour ajouter votre commerce, contactez-nous via l\'email support@locacharge.ci ou appelez le +225 0123456789.',
                ),
                _buildFAQItem(
                  question: 'Les prix sont-ils à jour ?',
                  answer:
                      'Nous nous efforçons de maintenir les prix à jour, mais nous vous recommandons de vérifier directement auprès du commerçant.',
                ),
                _buildFAQItem(
                  question: 'Comment signaler un problème ?',
                  answer:
                      'Utilisez la fonction "Signaler un problème" dans le profil du commerçant ou contactez-nous directement.',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Contact
            _buildSection(
              title: 'Contact',
              icon: Icons.contact_support,
              children: [
                _buildContactItem(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: 'support@locacharge.ci',
                  onTap: () {
                    // Ouvrir l'email
                  },
                ),
                _buildContactItem(
                  icon: Icons.phone,
                  title: 'Téléphone',
                  subtitle: '+225 0123456789',
                  onTap: () {
                    // Appeler
                  },
                ),
                _buildContactItem(
                  icon: Icons.chat,
                  title: 'WhatsApp',
                  subtitle: '+225 0123456789',
                  onTap: () {
                    // Ouvrir WhatsApp
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section À propos
            Text(
              'À propos de LocaCharge',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickGuide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGuideStep(
              icon: Icons.map,
              title: '1. Utilisez la carte',
              description:
                  'Explorez la carte interactive pour voir tous les commerçants autour de vous.',
            ),
            const Divider(),
            _buildGuideStep(
              icon: Icons.filter_list,
              title: '2. Filtrez les résultats',
              description:
                  'Utilisez les filtres pour trouver exactement ce que vous cherchez (recharges, Mobile Money, etc.).',
            ),
            const Divider(),
            _buildGuideStep(
              icon: Icons.info,
              title: '3. Consultez les détails',
              description:
                  'Appuyez sur un commerçant pour voir ses informations complètes et sa disponibilité.',
            ),
            const Divider(),
            _buildGuideStep(
              icon: Icons.directions,
              title: '4. Obtenez l\'itinéraire',
              description:
                  'Utilisez le bouton "Itinéraire" pour vous y rendre facilement.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Card(
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            _faqItems[panelIndex].isExpanded = !isExpanded;
          });
        },
        children: _faqItems.map((faq) {
          return ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return ListTile(
                title: Text(
                  faq.question,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(faq.answer),
            ),
            isExpanded: faq.isExpanded,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 32),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LocaCharge',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'LocaCharge est une application mobile qui connecte les utilisateurs aux points de recharge téléphonique et services numériques en Côte d\'Ivoire. Notre mission est de faciliter l\'accès aux services numériques essentiels.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Version: '),
                Text(
                  '1.0.0',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('© 2024 LocaCharge. Tous droits réservés.'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@locacharge.ci',
      query: 'subject=Support LocaCharge',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+2252722498989',
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.locacharge.ci');

    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchFacebook() async {
    final Uri facebookUri = Uri.parse('https://www.facebook.com/locachargeci');

    if (await canLaunchUrl(facebookUri)) {
      await launchUrl(facebookUri, mode: LaunchMode.externalApplication);
    }
  }
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}
