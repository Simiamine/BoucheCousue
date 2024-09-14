program BoucheCousue;
uses crt, sysutils;


Type tab = array[1..6] of array [1..10] of string;
Type alphabet = array[1..26] of integer;

//Constantes qui nous servirons pour la procédure menu
CONST UP = #72;
	DOWN = #80;
	LEFT = #75;
	RIGHT = #77;
	ENTER = #13;
	
procedure AffichageGrille(var grille, placement : tab; var motmyst : String);
	var i,k : integer;
	// Procédure qui va permettre d''afficher la grille en utilisant le tableau produit par la procédure vérif lettre
	
	begin
		gotoxy(10,5);
		for i:=1 to 6 do begin
		for k:=1 to length(motmyst) do
		// En fonction de ce qui est inscrit dans la fonction verif lettre va afficher la lettre avec une couleur différente : Rouge si elle est bien placée, jaune si elle est présente et bleu sinon

			begin
				if placement[i][k] = 'absent' then TextBackground(Blue);
				if placement[i][k] = 'present' then TextBackground(Yellow);
				if placement[i][k] = 'place' then TextBackground(Red);
				Write (grille[i][k]);
				TextBackground(Black);
				Write (' ');
			end;
		gotoxy(10,5+2*i); 
		end;
	// Ainsi, vu que chaque tentative est enregistrée dans le tableau 'grille', nous allons pouvoir réafficher le tableau à chaque fois
	end;
	
function MotCorrect(var motmyst, essai : String): Boolean;
// Fonction qui retourne si oui ou non le mot est correct
	var lettresplace, i : integer;
	begin
		lettresplace:=0;
		MotCorrect:=False;
		for i:=1 to length(motmyst) do
			begin
				if essai[i]=motmyst[i] then lettresplace:=lettresplace+1;
			end;
		if lettresplace=length(motmyst) then MotCorrect:=True;
	end;


procedure MotConforme(var mot : String);
//Procédure qui vise à uniformiser les mots pour mieux pouvoir les comparer. Ainsi, tous les mots seront en Majuscule sans accent pour faire plus simple.
	var i : integer;
	begin
		for i:=1 to length(mot) do
		begin
		if (mot[i] = 'z') OR (mot[i] = 'è') OR (mot[i] = 'ë') OR (mot[i] = 'ê') OR (mot[i] = 'Ë') OR (mot[i] = 'Ê') OR (mot[i] = 'É') OR (mot[i] = 'È') then mot[i]:='E';
		if (mot[i] = 'á') OR (mot[i] = 'à') OR (mot[i] = 'ä') OR (mot[i] = 'â') OR (mot[i] = 'Ä') OR (mot[i] = 'Â') then mot[i]:='A';
		if (mot[i] = 'í') OR (mot[i] = 'ì') OR (mot[i] = 'ï') OR (mot[i] = 'î') OR (mot[i] = 'Ï') OR (mot[i] = 'Î') then mot[i]:='I';
		if (mot[i] = 'ö') OR (mot[i] = 'ô') OR (mot[i] = 'Ö') OR (mot[i] = 'Ô') then mot[i]:='O';
		if (mot[i] = 'ü') OR (mot[i] = 'û') OR (mot[i] = 'Ü') OR (mot[i] = 'Û') then mot[i]:='U';
		end;
		mot:=Uppercase(mot);
	end;

Function OccurencesLettres(var mot : string):alphabet;
// cette fonction va créer un tableau qui va compter le nombre de fois que chaque lettre apparait
	var lettres : alphabet;
	var i, ordre : integer;
	begin
	MotConforme(mot);
	//ici on converti des entiers en lettres et vice versa pour mieux pouvoir les manipuler et les comparer
	for i:=1 to 26 do lettres[i]:=0;
	for i:=1 to length(mot) do
		begin
		ordre:=ord(mot[i])-64;
		lettres[ordre]:=lettres[ordre]+1;
		end;
	OccurencesLettres:=lettres;	
	end;
	
Procedure AbsenceLettres(var tour: integer; var Clavier:alphabet; var placement, grille : tab; motmyst : string);
// cette procédure répertorie les lettres absentes du mot
	var k: integer;
	var lettre : char;
	begin 
		for k:=1 to length(motmyst) do
			lettre := grille[tour][k][1];
			if placement[tour][k] = 'absent' then Clavier[ord(lettre)]:=1;
	end;

		
procedure veriflettre(var grille, placement : tab; occurences :alphabet; var motmyst : String; var tour, pos : Integer);
// Procédure qui va vérifier si une lettre est bien placée, présente ou non dans le mot mystere
	var verif : string;
	var i, ordreNumero : integer;
	var lettres : alphabet;
	begin 
		lettres := occurences;
		verif := 'absent';
		for i:=1 to length(motmyst) do
			begin
			// Ici on converti des entiers en lettres et vice versa pour mieux pouvoir les manipuler et les comparer
			ordreNumero:=ord(motmyst[i])-64; 
			if(grille[tour][pos]=motmyst[i]) and (lettres[ordreNumero]>0) then 
				begin 
					verif:= 'present';
					lettres[ordreNumero]:=lettres[ordreNumero]-1;
				end;
			end;	
		if grille[tour][pos]=motmyst[pos] then 
			verif := 'place';
	placement[tour][pos]:=verif;
	end;
	
Function NombreLignes(NomFichier:string):integer;
// Fonction qui compte le nombre de lignes d'un fichier. On s'en sert pour pouvoir appliquer le random sur le fichier qui contient les mots proposables notemment
	var Fichier : TextFile;
	var nbLignes : integer;
	begin
		nblignes:=0;
		Assign(Fichier, NomFichier);
		Reset(Fichier);
		Repeat
			Readln(Fichier);
			nbLignes:= nbLignes+1;
		Until(EOF(Fichier));
		NombreLignes:=nblignes;
	end;
		
function mothasard():string;
// Cette fonction va tirer un mot au hasard dans le fichier de mots proposables
	var i, ligne : Integer;
	var mot : string;
	var Fichier : TextFile;
	begin
	Randomize;
	Assign(Fichier, 'Dico_Tirage.txt');
	Reset(Fichier);
	ligne := Random(NombreLignes('Dico_Tirage.txt'));
	for i:=0 to	ligne do
	begin
	readln(Fichier, mot);
	end;	
	mothasard:=mot;	
	end;

Function VerificationMotExistant(mot : string):Boolean;
// Cette fonction verifie si le mot existe
	Var existe : boolean;
	var Fichier : TextFile;
	var ligne : string;
	begin
		MotConforme(mot);
		existe:= False;
		Assign(Fichier, 'Dico_Verif.txt');
		Reset(Fichier);
		Repeat
			readln(Fichier,ligne);
			MotConforme(ligne);
			if ligne=mot then existe:=True
		until EOF(Fichier) or existe=True;
	VerificationMotExistant:=existe;
	end;

procedure partie();
// cette procedure veille au bon déroulement de la partie grace aux procedures et fonctions detaillees ci dessus
// A chaque tentative, le jeu va afficher la grille complete mise a jour avec les indications donnes grace a veriflettres notemment
	var essai, motmyst : string;
	var tour, pos, i, a, b, apres: integer;
	var grille, placement : tab;
	var clavier, occurences : alphabet;	
	begin
	motmyst:= mothasard();
	writeln ('Le mot a trouver comporte ' , length(motmyst), ' lettres.');
	Motconforme(motmyst);
	Occurences:=OccurencesLettres(motmyst);
	tour:=0;
	for a:=1 to 6 do
		for b:=1 to length(motmyst) do
			begin
				placement[a][b]:='absent';
				grille[a][b]:=' ';
			end;
	grille[1][1]:=motmyst[1];
	placement[1][1]:='place';
	AffichageGrille(grille, placement, motmyst);		
	repeat
		writeln('   '); readln(essai);
		Motconforme(essai);
		if (length (essai)=length(motmyst)) and (VerificationMotExistant(essai)=True) then
			begin
			tour:=tour+1;
				for i:=1 to length(motmyst) do 
					begin 
						grille[tour][i]:=essai[i];
						pos:=i;
						veriflettre(grille, placement, occurences, motmyst, tour, pos);
					end;	
			end;
		ClrScr;
		writeln ('Le mot a trouver comporte ' , length(motmyst), ' lettres.');
		apres:=tour+1;
		if apres<>7 then begin
			Grille[apres][1]:=motmyst[1];
			Placement[apres][1]:='place';
		end;
		AffichageGrille(grille, placement, motmyst);
		AbsenceLettres(tour, Clavier, placement, grille, motmyst);
		Writeln('');
		if length(essai)<>length(motmyst) then writeln('Votre mot doit comporter ',length(motmyst),' lettres');
		if VerificationMotExistant(essai)=False then writeln('Veuillez rentrer un mot existant');
		{writeln('Lettres absentes : ');
		for i:=1 to 26 do if write(Clavier[i])=1 then write(chr(i+64), ' ')};
	until (tour=6) OR (motCorrect(motmyst, essai)=True);
	If (tour=6) AND (motCorrect(motmyst, essai)<>True) 
		then writeln('Vous avez perdu ! Le mot etait ', motmyst, '.')
		else writeln('Bravo !');
	end;

procedure affiche(c :Char; posX,posY : Integer);
begin
    ClrScr;
   
    Writeln('');
    Writeln('');
		Writeln('    PARTIE');
		Writeln('');
		Writeln('    Regles');
    
    gotoXY(posX,posY);
    write(c);
    
    
end;
    
procedure menu();
//un menu qui va nous rediriger vers differents ecrans en fonction de ce que l''utilisateur aura selectionne grace aux touches du clavier
// la procedure menu va appeler la procedure partie notemment qui elle même va appeler toutes les autres procedures
var
    x, y : integer;
    key : Char;
begin
    x := 2;
    y := 3;
    	
    Repeat
   
        affiche('*',x,y);
	
		
		key := readKey();
		if key = #0 then
		begin
            key:=ReadKey();
            case key of
				
				
				DOWN : if y < 5 then
							begin
							y := y + 2;
			
							
							end;
							
					
				UP : if y > 3 then
							begin
							y := y - 2;
							end;
				
			end ;				
            
				Case y of
				3:Begin 
				Write('Partie');
				end;
				5: begin
				Write('Regles');
				
				end;
		end ;
		end ;
				
	until key = #13;
	Clrscr;
	key := #0;
	case y of 
		3 : Partie();
			
		5 : begin
			// On detaille ici les regles du jeu
			writeln('Tentez de deviner le mot mystere. Vous avez 6 tentatives pour le trouver.');writeln('');
			Writeln('Vous ne pouvez disposer que de noms communs presents dans le dictionnaire');writeln('');
			writeln('     ');Write('                   ');
			TextBackground(Red); Write('B'); TextBackground(Black); Write(' ');
			TextBackground(Yellow); Write('O'); TextBackground(Black); Write(' ');
			TextBackground(Blue); Write('N'); TextBackground(Black); Write(' ');
			TextBackground(Red); Write('J'); TextBackground(Black); Write(' ');
			TextBackground(Blue); Write('O'); TextBackground(Black); Write(' ');
			TextBackground(Blue); Write('U'); TextBackground(Black); Write(' ');
			TextBackground(Red); Write('R'); TextBackground(Black); Writeln(''); writeln('');Writeln('');
			writeln('Les lettres entourees d''un carre rouge sont bien placees');writeln('');
			writeln('Les lettres entourees d''un carre jaune sont presentes mais mal placees');writeln('');
			writeln('Les lettres qui restent sur fond bleu ne sont pas dans le mot.');writeln('');
			Writeln('Bonne chance !');writeln('');
			Writeln('');writeln('');writeln('');
			Writeln('Appuyez sur entrer  pour demarrer une partie.');
		Repeat
		key := readKey();
		until key = #13;
		if key = #13 then
		Begin
		ClrScr;
		Menu();
		end; 
		end;
	end;
end;


begin
menu();
end.
