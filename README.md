# garde-fou-cpu-vps

Un petit service qui évite qu'un hébergeur de VPS ne plafonne votre serveur parce qu'il a tourné trop fort trop longtemps, et une commande, `lourd`, pour lancer les gros travaux dans une tranche de CPU limitée.

Contexte : chez certains hébergeurs (testé chez Hostinger, VPS à 2 cœurs), une utilisation du CPU de 60 à 90 % pendant quelques heures déclenche une limitation (le « steal » monte à 80 %). Ce dépôt mesure la charge et agit avant.

## Ce que contient le dépôt
• `garde-fou-cpu` : script Python (bibliothèque standard seulement), lancé chaque minute par un timer systemd. Il mesure l'usage CPU réel (moyennes sur 5, 10, 30 et 60 min), et au-dessus du seuil d'alerte range les processus gourmands non protégés dans `batch.slice`, puis les met en pause si cela ne suffit pas. Tout est journalisé et réversible. Il reprend seul ses pauses quand la charge redescend.
• `lourd` : `lourd COMMANDE…` lance un travail dans `batch.slice` (plafond 50 % d'un cœur, priorité basse). `lourd --adopter PID…` range des processus déjà lancés. `lourd --statut` montre la tranche et ses jobs.
• `lourd-adopter` : l'aide root de `lourd`. Sous sudo, un utilisateur ne peut ranger que ses propres processus, et la seule chose qu'elle sait faire est de les mettre dans une tranche plus bridée.
• `systemd/` (tranche, service, timer), `config/` (exemples de réglages, sudoers, rotation des journaux).

## Installer
Prérequis : Linux avec systemd (cgroups v2), Python 3.8 ou plus, `busctl`.

```
git clone <ce dépôt> && cd garde-fou-cpu-vps
sudo ./install.sh VOTRE_COMPTE      # le compte reçoit le droit sudo de ranger ses processus
garde-fou-cpu statut
lourd --statut
lourd sleep 30                       # exemple : un travail rangé dans batch.slice
```

## Réglages
Fichier `/etc/garde-fou-cpu/config.json` (modèle : `config/config.example.json`). Rien n'est actif par défaut hors la mesure et le rangement. Pour aller plus loin :
• `reglages.vm_id` et le jeton dans `reglages.jeton_hostinger` (droits 600, jamais dans un dépôt) : active l'interrogation de l'API Hostinger pour confirmer un plafonnement.
• `reglages.ntfy_env` : fichier avec `NTFY_URL`, `NTFY_TOPIC`, `NTFY_TOKEN` (modèle `config/ntfy.env.example`) pour les notifications, silencieuses la nuit (`nuit`, `fuseau`).
• `reglages.commande_alarme`, `utilisateur_alarme`, `commande_alerte` : commandes de votre choix appelées en cas de plafonnement avéré.
• `proteges` : processus, utilisateurs, ports et unités que le garde-fou ne touche jamais.

Commandes : `garde-fou-cpu statut | reprendre ID|tout | liberer ID|tout | api | tick [--dry-run]`.

## Licences
Code : Apache 2.0 (`LICENSE`, `NOTICE`). Texte et documentation : CC BY 4.0 (`LICENSE-docs`). Aucune dépendance tierce.
