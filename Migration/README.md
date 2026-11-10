# Migration GPO inter-domaines — staging sans liens

Ce dossier permet la preparation d'une migration GPO vers un **domaine different du domaine source**. Les scripts sont une base de staging **a valider en laboratoire**. Ils ne sont pas certifies pour une execution en production.

## Contenu
- `Import-GpoStaging.ps1` : lire un Excel, filtrer `Final Action = To keep`, importer les sauvegardes selectionnees sans creer de liens, avec statut AllSettingsDisabled impose avant et apres import.
- `Export-WmiGpoSource.ps1` : export en lecture seule des filtres WMI et des associations GPO/WMI depuis le domaine source, lorsque l'acces sera disponible.
- `Test-GpoStaging.ps1` : controle post-import que les GPO importees n'ont pas de lien.

## Pre-requis
Windows PowerShell 5.1, RSAT GroupPolicy/ActiveDirectory, droits d'administration GPO adaptes sur le domaine cible. Installer ImportExcel avec :

```powershell
Install-Module ImportExcel -Scope CurrentUser
```

Le fichier Excel doit avoir les colonnes `Name`, `Final Action`, `ID`. Stocker les backups et l'inventaire hors du depot GitHub public.

## Sur le second PC

```powershell
git clone --branch AD_Exchange_O365 https://github.com/mohel023/System.git
cd .\System\Migration
```

Simulation (creer C:\MigrationData pour le rapport) :

```powershell
.\Import-GpoStaging.ps1 -ExcelPath 'C:\MigrationData\GPO-List.xlsx' -BackupPath 'C:\MigrationData\Backups' -TargetDomain 'target.example.local' -ReportPath 'C:\MigrationData\ImportReport.csv' -WhatIf
```

Importer apres revue : retirer `-WhatIf` et repondre a la demande de confirmation. Aucune liaison GPO n'est creee dans ces scripts. Verifier ensuite :

```powershell
.\Test-GpoStaging.ps1 -TargetDomain 'target.example.local' -ReportPath 'C:\MigrationData\ImportReport.csv' -OutputPath 'C:\MigrationData'
```

## Filtres WMI (acces source futur)
```powershell
.\Export-WmiGpoSource.ps1 -Domain 'source.example.local' -OutputFolder 'C:\MigrationData\WmiExport'
```

L'export seul ne restaure ni ne rattache les filtres WMI sur le domaine cible. Une phase distincte et revue doit etre preparee pour la recreation des objets et associations.

## Vigilance
- Ne jamais ecraser une GPO existante ni la lier sans revue explicite.
- Les GUID cible different des GUID source ; conserver le rapport de correspondance.
- Table de migration potentiellement necessaire pour SID/groupes et chemins UNC.
- Filtrages de securite, permissions, scripts de connexion et references au domaine source a auditer.
- Les sauvegardes GPO ne constituent pas un export complet des objets filtres WMI.

## Securite obligatoire
Les GPO nouvellement creees sont desactivees (AllSettingsDisabled) avant l'import puis de nouveau apres l'import. Le script confirme le statut et l'absence de liens. En cas d'erreur avec un GUID cible, verifier immediatement cette GPO dans GPMC. Le traitement n'est pas transactionnel et n'a pas ete valide en production.
