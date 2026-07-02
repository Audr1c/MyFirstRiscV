I used this prompt to Gemini 3.5 Flash to have a good strat plan of what to do :
```txt
Agis comme un expert en conception numérique. Je dois coder un processeur RISC-V (RV32I) de zéro en Verilog pour me former. Donne-moi un plan étape par étape pour le concevoir (Program Counter, Instruction Memory, Decoder, ALU, Register File).
Mon niveau : je connais le language, mais jamais fait de projet complet 
Me donne pas trop d'indice et laisse moi trouver, je demanderais explicitement quand je veux une aide ou une solution 
```
(geminiConv)[https://gemini.google.com/app/695e89d55cb2cd5c]

Voici le plan d'action étape par étape pour concevoir ton processeur RV32I en architecture **monocycle** (une instruction par cycle d'horloge), ce qui est le choix le plus logique pour un premier projet.

### Étape 1 : L'Unité Arithmétique et Logique (ALU)

* **Objectif** : Créer un bloc purement combinatoire.
* **Entrées/Sorties** : Deux opérandes de 32 bits, un code d'opération (ALUControl), et en sortie le résultat 32 bits ainsi qu'un flag "Zero" (indispensable pour les branchements).
* **Opérations à supporter** : ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU.

### Étape 2 : Le Banc de Registres (Register File)

* **Objectif** : Gérer les 32 registres généraux de l'architecture.
* **Spécifications** : 2 ports de lecture (asynchrones/combinatoires) et 1 port d'écriture (synchrone sur front d'horloge, conditionné par un signal `RegWrite`).
* **Règle RISC-V** : Le registre `x0` doit être câblé à zéro en permanence.

### Étape 3 : Le Program Counter (PC) et l'Instruction Memory

* **Objectif** : Gérer le pointeur d'instruction et la lecture du code.
* **PC** : Un registre simple de 32 bits mis à jour à chaque front d'horloge.
* **Instruction Memory** : Une mémoire synchrone ou asynchrone (pour commencer) qui prend le PC en entrée et renvoie l'instruction 32 bits associée.

### Étape 4 : Le Décodeur et Générateur d'Immédiats

* **Objectif** : Traduire l'instruction machine.
* **Découpage** : Extraire les champs fixes (Opcode, Rd, Rs1, Rs2, Funct3, Funct7).
* **Générateur d'immédiats** : Reconstruire l'opérande immédiat 32 bits en fonction du type d'instruction (I, S, B, U, J) en respectant l'extension de signe.

### Étape 5 : L'Unité de Contrôle (Control Unit)

* **Objectif** : Générer les signaux de commande du processeur à partir de l'Opcode et des Funct3/Funct7.
* **Signaux à générer** : `RegWrite`, `ALUSrc` (choix entre la deuxième source registre ou l'immédiat), `ALUControl`, `MemWrite`, `MemToReg`, `PCSrc` (choix du prochain PC).

### Étape 6 : Assemblage du Datapath de Base (Type-R et Type-I)

* **Objectif** : Connecter les blocs pour faire fonctionner les instructions de calcul simples (ex: `ADD`, `ADDI`).
* **Action** : Créer le module `top` qui interconnecte le PC, l'Instruction Memory, le Register File, le Décodeur, l'Unité de Contrôle et l'ALU.

### Étape 7 : Ajout de la Data Memory (Load / Store)

* **Objectif** : Prendre en charge les accès mémoire (`LW`, `SW`).
* **Action** : Intégrer un bloc RAM (Data Memory) synchrone en écriture. Connecter la sortie de l'ALU à l'adresse de cette mémoire, et multiplexer la sortie de la RAM avec le résultat de l'ALU pour l'écriture dans le Register File.

### Étape 8 : Gestion des Branchements et Sauts (Jumps & Branches)

* **Objectif** : Permettre les ruptures de séquence (`BEQ`, `BNE`, `JAL`, `JALR`).
* **Action** : Ajouter la logique de calcul du PC alternatif (PC + Immédiat ou Rs1 + Immédiat) et modifier l'entrée du registre PC via un multiplexeur piloté par l'Unité de Contrôle et le flag de l'ALU.

### Étape 9 : Validation via Testbench

* **Objectif** : Vérifier le bon fonctionnement global.
* **Action** : Écrire un banc d'essai qui charge un fichier binaire d'instructions simples (via `$readmemh`) dans l'Instruction Memory et observer le comportement des registres à l'aide de vcd/GTKWave.

---

Indique-moi par quelle étape tu souhaites commencer ou dès que tu as validé ton premier bloc.