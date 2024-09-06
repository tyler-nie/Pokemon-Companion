DROP TABLE FoundIn;

DROP TABLE BelongsTo;

DROP TABLE BattlesIn;

DROP TABLE CatchableIn;

DROP TABLE HasMove;

DROP TABLE Pokemon;

DROP TABLE Move;

DROP TABLE Item;

DROP TABLE PokemonType;

DROP TABLE Type;

DROP TABLE Ability;

DROP TABLE PokemonSpecies;

DROP TABLE InGame;

DROP TABLE Location;

DROP TABLE Game;

DROP TABLE Opponent;

DROP TABLE Player;

DROP TABLE Team;

DROP TABLE PlayerCity;

DROP TABLE PlayerProvince;

DROP TABLE PokemonTrainer;

-- -------------------------------------------------------------------------

CREATE TABLE PokemonTrainer(
    TrainerID RAW(16),
    TrainerName VARCHAR(50),
    PRIMARY KEY(TrainerID)
);

CREATE TABLE PlayerProvince(
    PostalCode CHAR(6),
    Province VARCHAR(100),
    PRIMARY KEY(PostalCode)
);

CREATE TABLE PlayerCity(
    PostalCode CHAR(6),
    City VARCHAR(100),
    PRIMARY KEY(PostalCode)
);

CREATE TABLE Team(
    TeamID RAW(16),
    TeamName VARCHAR(50),
    TrainerID RAW(16) NOT NULL,
    PRIMARY KEY(TeamID),
    FOREIGN KEY(TrainerID) REFERENCES PokemonTrainer
        ON DELETE CASCADE
);

CREATE TABLE Player(
    Username VARCHAR(50) NOT NULL,
    TrainerID RAW(16),
    JoinDate CHAR(10),
    Email VARCHAR(100),
    StreetAddress VARCHAR(100),
    PostalCode CHAR(6) NOT NULL,
    PRIMARY KEY(TrainerID),
    UNIQUE (Email),
    UNIQUE (Username),
    FOREIGN KEY(TrainerID) REFERENCES PokemonTrainer
        ON DELETE CASCADE,
    FOREIGN KEY(PostalCode) REFERENCES PlayerProvince,
    FOREIGN KEY(PostalCode) REFERENCES PlayerCity
);

CREATE TABLE Opponent(
    TrainerID RAW(16),
    TrainerClass VARCHAR(50),
    PRIMARY KEY(TrainerID),
    FOREIGN KEY (TrainerID) REFERENCES PokemonTrainer
        ON DELETE CASCADE
);

CREATE TABLE Game(
    GameName VARCHAR(50),
    GenerationNumber VARCHAR(10),
    Console VARCHAR(50),
    PRIMARY KEY(GameName)
);

CREATE TABLE Location(
    LocationName VARCHAR(50),
    RegionName VARCHAR(50),
    HasGym INTEGER,
    PRIMARY KEY(LocationName, RegionName)
);

CREATE TABLE InGame(
    LocationName VARCHAR(50),
    RegionName VARCHAR(50),
    GameName VARCHAR(50),
    PRIMARY KEY(LocationName, RegionName, GameName),
    FOREIGN KEY(LocationName, RegionName) REFERENCES Location
        ON DELETE CASCADE,
    FOREIGN KEY(GameName) REFERENCES Game
        ON DELETE CASCADE
);

CREATE TABLE PokemonSpecies(
    EvolvingIntoSpecieName VARCHAR(50),
    EffortValue VARCHAR(40),
    EvolvedFromSpecieName VARCHAR(50),
    EvolvedLevel INTEGER,
    CHECK (EvolvedLevel >= 0),
    PRIMARY KEY(EvolvingIntoSpecieName),
    FOREIGN KEY(EvolvedFromSpecieName) REFERENCES
        PokemonSpecies(EvolvingIntoSpecieName)
            ON DELETE SET NULL
);

CREATE TABLE Ability(
    AbilityName VARCHAR(50),
    AbilityDescription VARCHAR(200),
    PRIMARY KEY (AbilityName),
    UNIQUE (AbilityDescription)
);

CREATE TABLE Type(
    TypeName VARCHAR(50),
    GenerationAdded VARCHAR(10),
    PRIMARY KEY(TypeName)
);

CREATE TABLE PokemonType(
    SpecieName VARCHAR(50),
    TypeName VARCHAR(50),
    PRIMARY KEY(SpecieName, TypeName),
    FOREIGN KEY(SpecieName) REFERENCES
        PokemonSpecies(EvolvingIntoSpecieName)
            ON DELETE CASCADE,
    FOREIGN KEY(TypeName) REFERENCES Type
        ON DELETE CASCADE
);

CREATE TABLE Item(
    ItemName VARCHAR(50),
    IsReusable INTEGER,
    PRIMARY KEY(ItemName)
);

CREATE TABLE Move(
    MoveName VARCHAR(50),
    Power INTEGER,
    Accuracy INTEGER,
    BasePP INTEGER,
    Category VARCHAR(20),
    TypeName VARCHAR(50) NOT NULL,
    PRIMARY KEY(MoveName),
    FOREIGN KEY(TypeName) REFERENCES Type
        ON DELETE CASCADE
);

CREATE TABLE Pokemon(
    PokemonID RAW(16),
    PokemonName VARCHAR(50),
    Gender CHAR(1),
    SpecieName VARCHAR(50),
    AbilityName VARCHAR(50) NOT NULL,
    ItemName VARCHAR(50),
    PokemonLevel INTEGER,
    OwnerID RAW(16) NOT NULL,
    CHECK (PokemonLevel >= 0),
    PRIMARY KEY(PokemonID, SpecieName),
    FOREIGN KEY(AbilityName) REFERENCES Ability
        ON DELETE CASCADE,
    FOREIGN KEY(ItemName) REFERENCES Item,
    FOREIGN KEY(SpecieName) REFERENCES
        PokemonSpecies(EvolvingIntoSpecieName)
            ON DELETE CASCADE,
    FOREIGN KEY(OwnerID) REFERENCES PokemonTrainer(TrainerID)
        ON DELETE CASCADE
);

CREATE TABLE HasMove(
    PokemonID RAW(16),
    SpecieName VARCHAR(50),
    MoveName VARCHAR(50),
    PRIMARY KEY(PokemonID, SpecieName, MoveName),
    FOREIGN KEY(PokemonID, SpecieName) REFERENCES Pokemon
        ON DELETE CASCADE,
    FOREIGN KEY(MoveName) REFERENCES Move
        ON DELETE CASCADE
);

CREATE TABLE CatchableIn(
    SpecieName VARCHAR(50),
    LocationName VARCHAR(50),
    RegionName VARCHAR(50),
    GameName VARCHAR(50),
    PRIMARY KEY(SpecieName, LocationName, RegionName, GameName),
    FOREIGN KEY(SpecieName)
        REFERENCES PokemonSpecies(EvolvingIntoSpecieName)
            ON DELETE CASCADE,
    FOREIGN KEY(LocationName, RegionName, GameName)
        REFERENCES InGame
            ON DELETE CASCADE
);

CREATE TABLE BattlesIn(
    TrainerID RAW(16),
    LocationName VARCHAR(50),
    RegionName VARCHAR(50),
    GameName VARCHAR(50),
    PRIMARY KEY(TrainerID, LocationName, RegionName, GameName),
    FOREIGN KEY(TrainerID) REFERENCES Opponent
    ON DELETE CASCADE,
    FOREIGN KEY(LocationName, RegionName, GameName)
        REFERENCES InGame
            ON DELETE CASCADE
);

CREATE TABLE BelongsTo(
    TeamID RAW(16),
    PokemonID RAW(16),
    SpecieName VARCHAR(50),
    PRIMARY KEY (TeamID, PokemonID, SpecieName),
    FOREIGN KEY (TeamID) REFERENCES Team
        ON DELETE CASCADE,
    FOREIGN KEY (PokemonID, SpecieName) REFERENCES Pokemon
        ON DELETE CASCADE
);

CREATE TABLE FoundIn(
    ItemName VARCHAR(50),
    LocationName VARCHAR(50),
    RegionName VARCHAR(50),
    GameName VARCHAR(50),
    PRIMARY KEY(ItemName, LocationName, RegionName, GameName),
    FOREIGN KEY(ItemName) REFERENCES Item
        ON DELETE CASCADE,
    FOREIGN KEY(LocationName, RegionName, GameName)
        REFERENCES InGame
            ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------

INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(1), 'Tyler');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(9999), 'Herman');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
	(UTL_RAW.CAST_TO_RAW(8), 'Leah');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(320), 'Kristelle');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(6), 'TestUser');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(7), 'Ivan');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(101), 'Opponent1');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(102), 'Opponent2');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(103), 'Opponent3');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(104), 'Opponent4');
INSERT INTO PokemonTrainer (TrainerID, TrainerName)
VALUES
    (UTL_RAW.CAST_TO_RAW(105), 'Opponent5');

--

INSERT INTO PlayerProvince (PostalCode, Province)
VALUES
	('R3A1E9', 'Manitoba');
INSERT INTO PlayerProvince (PostalCode, Province)
VALUES
	('V7P1S3', 'British Columbia');
INSERT INTO PlayerProvince (PostalCode, Province)
VALUES
	('V6T1Z4', 'British Columbia');
INSERT INTO PlayerProvince (PostalCode, Province)
VALUES
	('S4L5B1', 'Saskatchewan');
INSERT INTO PlayerProvince (PostalCode, Province)
VALUES
	('T3A5G5', 'Alberta');
INSERT INTO PlayerProvince (PostalCode, Province)
VALUES
	('C0A1R0', 'Prince Edward Island');

--

INSERT INTO PlayerCity (PostalCode, City)
VALUES
	('R3A1E9', 'Winnipeg');
INSERT INTO PlayerCity (PostalCode, City)
VALUES
	('V7P1S3', 'North Vancouver');
INSERT INTO PlayerCity (PostalCode, City)
VALUES
	('V6T1Z4', 'Vancouver');
INSERT INTO PlayerCity (PostalCode, City)
VALUES
	('S4L5B1', 'White City');
INSERT INTO PlayerCity (PostalCode, City)
VALUES
	('T3A5G5', 'Calgary');
INSERT INTO PlayerCity (PostalCode, City)
VALUES
    ('C0A1R0', 'Montague');

--

INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(301), UTL_RAW.CAST_TO_RAW(101), 'Starter Team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(302), UTL_RAW.CAST_TO_RAW(102), 'Just a mamoswine');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(303), UTL_RAW.CAST_TO_RAW(103), 'Cool Team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(304), UTL_RAW.CAST_TO_RAW(104), 'Different Sized Fire Breathing Lizards');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(305), UTL_RAW.CAST_TO_RAW(105), 'Get ready for splash');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(306), UTL_RAW.CAST_TO_RAW(105), 'Weak turtle');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(307), UTL_RAW.CAST_TO_RAW(105), 'One Pokemon Team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(308), UTL_RAW.CAST_TO_RAW(105), 'Two Pokemon Team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(309), UTL_RAW.CAST_TO_RAW(105), 'Three Pokemon Team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(310), UTL_RAW.CAST_TO_RAW(105), 'Strong 1 Pokemon Team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(311), UTL_RAW.CAST_TO_RAW(105), 'Strong 2 Pokemon Team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(1), UTL_RAW.CAST_TO_RAW(1), 'The bestest pokemon masters team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(2), UTL_RAW.CAST_TO_RAW(1), 'Super weak test team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(3), UTL_RAW.CAST_TO_RAW(1), 'Test team1');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(4), UTL_RAW.CAST_TO_RAW(1), 'Test team2');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(5), UTL_RAW.CAST_TO_RAW(1), 'Test team3');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(402), UTL_RAW.CAST_TO_RAW(9999), 'Yes thats the team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(403), UTL_RAW.CAST_TO_RAW(8), 'Second Best Team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(404), UTL_RAW.CAST_TO_RAW(7), 'Big Ivs team');
INSERT INTO Team (TeamID, TrainerID, TeamName)
VALUES
	(UTL_RAW.CAST_TO_RAW(405), UTL_RAW.CAST_TO_RAW(320), 'even better team');

--

INSERT INTO Player (Username, TrainerID, JoinDate, PostalCode, StreetAddress, Email)
VALUES
    ('tyler', UTL_RAW.CAST_TO_RAW(1), '05/14/2003', 'V7P1S3', '16th Street', 'tyleristhebest@gmail.com');
INSERT INTO Player (Username, TrainerID, JoinDate, PostalCode, StreetAddress, Email)
VALUES
    ('test user', UTL_RAW.CAST_TO_RAW(9999), '12/20/2018', 'R3A1E9', '84 Isabel St', 'genericemail@gmail.com');
INSERT INTO Player (Username, TrainerID, JoinDate, PostalCode, StreetAddress, Email)
VALUES
    ('leah', UTL_RAW.CAST_TO_RAW(8), '09/01/2003', 'V6T1Z4', '6339 Stores Rd', 'museum@ubc.ca');
INSERT INTO Player (Username, TrainerID, JoinDate, PostalCode, StreetAddress, Email)
VALUES
    ('herman', UTL_RAW.CAST_TO_RAW(320), '09/22/2022', 'S4L5B1', '29 Ridgedale Bay', 'hermansemail@hotmail.com');
INSERT INTO Player (Username, TrainerID, JoinDate, PostalCode, StreetAddress, Email)
VALUES
    ('TESTTT', UTL_RAW.CAST_TO_RAW(7), '04/01/2017', 'T3A5G5', '17 Hamptons Cir NW', 'areallylongemail@yahoo.ca');
INSERT INTO Player (Username, TrainerID, JoinDate, PostalCode, StreetAddress, Email)
VALUES
    ('PeRson', UTL_RAW.CAST_TO_RAW(6), '11/05/2001', 'C0A1R0', '41 Wood Islands Rd', 'testemail@gmail.com');

--

INSERT INTO Opponent (TrainerID, TrainerClass)
VALUES
	(UTL_RAW.CAST_TO_RAW(101), 'Swimmer');
INSERT INTO Opponent (TrainerID, TrainerClass)
VALUES
	(UTL_RAW.CAST_TO_RAW(102), 'Miner');
INSERT INTO Opponent (TrainerID, TrainerClass)
VALUES
	(UTL_RAW.CAST_TO_RAW(103), 'Kid');
INSERT INTO Opponent (TrainerID, TrainerClass)
VALUES
	(UTL_RAW.CAST_TO_RAW(104), 'Team Rocket');
INSERT INTO Opponent (TrainerID, TrainerClass)
VALUES
	(UTL_RAW.CAST_TO_RAW(105), 'Team Plasma');

--

INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('Red', 'I', 'Game Boy');
INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('Blue', 'I', 'Game Boy');
INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('Emerald', 'III', 'Game Boy Advance');
INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('White', 'V', ' Nintendo DS');
INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('Black', 'V', ' Nintendo DS');
INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('Moon', 'VII', '3DS');
INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('Sun', 'VII', '3DS');
INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('Scarlet', 'IX', 'Switch');
INSERT INTO Game (GameName, GenerationNumber, Console)
VALUES
	('Violet', 'IX', 'Switch');

--

INSERT INTO Location (LocationName, RegionName, HasGym)
VALUES
	('Route 2', 'Kanto', 0);
INSERT INTO Location (LocationName, RegionName, HasGym)
VALUES
	('Power Plant', 'Viridian Forest', 0);
INSERT INTO Location (LocationName, RegionName, HasGym)
VALUES
	('Sandgem Flats', 'Hisui', 0);
INSERT INTO Location (LocationName, RegionName, HasGym)
VALUES
	('Route 4', 'Alola', 0);
INSERT INTO Location (LocationName, RegionName, HasGym)
VALUES
	('Dreamyard', 'Unova', 1);

--

INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Dreamyard', 'Unova', 'Sun');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Route 2', 'Kanto', 'Black');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Power Plant', 'Viridian Forest', 'Emerald');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Sandgem Flats', 'Hisui', 'Red');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Sandgem Flats', 'Hisui', 'Blue');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Route 4', 'Alola', 'Blue');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Route 2', 'Kanto', 'White');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Route 4', 'Alola', 'Violet');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Power Plant', 'Viridian Forest', 'Sun');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Power Plant', 'Viridian Forest', 'Moon');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Route 2', 'Kanto', 'Scarlet');
INSERT INTO InGame (LocationName, RegionName, GameName)
VALUES
	('Route 4', 'Alola', 'Emerald');

--

INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Jirachi', '3H', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Swinub', '1A', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Piloswine', '1H 1A', 'Swinub', 33);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Mamoswine', '3A', 'Piloswine', 34);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Igglybuff', '1H', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Jigglypuff', '2H', 'Igglybuff', 1);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Froakie', '1S', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Frogadier', '2S', 'Froakie', 16);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Greninja', '3S', 'Frogadier', 36);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Rayquaza', '2A 1SA', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Charmander', '1S', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Charmeleon', '1S 1SA', 'Charmander', 16);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Charizard', '3SA', 'Charmeleon', 36);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Bulbasaur', '1SA', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Squirtle', '1SA', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Pichu', '1S', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Pikachu', '2S', 'Pichu', 1);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Gastly', '1SA', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Haunter', '2SA', 'Gastly', 25);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Gengar', '3SA', 'Haunter', 26);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Magikarp', '1S', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Torchic', '1SA', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Combusken', '1A 1SA', 'Torchic', 16);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Blaziken', '3A', 'Combusken', 36);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Munchlax', '1H', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
	('Snorlax', '2H', 'Munchlax', 1);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
    ('Chimchar', '1S', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
    ('Monferno', '1SA 1S', 'Chimchar', 14);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
    ('Infernape', '1A 1SA 1S', 'Monferno', 36);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
    ('Tepig', '1H', NULL, 0);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
    ('Pignite', '2A', 'Tepig', 17);
INSERT INTO PokemonSpecies (EvolvingIntoSpecieName, EffortValue, EvolvedFromSpecieName, EvolvedLevel)
VALUES
    ('Emboar', '3A', 'Pignite', 36);

--

INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Overgrow', 'Increases the power of Grass-type moves by 50% when the users HP falls below 33.3% of the max health.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Torrent', 'Increases the power of Water-type moves by 50% when the users HP falls below 33.3% of the max health.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Static', 'When a hit makes contact with this pokemon inflicy paralyze 30% of the time');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Blaze', 'Increases the power of Fire-type moves by 50% when the users HP falls below 33.3% of the max health.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Cursed Body', 'Is able to disable any move used on this pokemon');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Thick Fat', 'Lessens the damage taken from fire-type and ice-type moves by 50%.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Synchronize', 'If the attacker burns, paralysises, or poisons this Pokemon, the opponent receives the same condition.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Cute Charm', 'If this Pokemon is hit by contact making move, the attacker will become infatuated 30% of the time.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Serene Grace', 'Doubles the chance of secondary effects.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Snow Cloak', 'Increases evasion by 20% in hail, and is immune to hail damage');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Competitive', 'Increases special attack by 2 stages when other stats are lowered.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Protean', 'Switches type to the type of the previous attack');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Air Lock', 'Ignores all weather effects.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Speed Boost', 'Increases speed over time.');
INSERT INTO Ability (AbilityName, AbilityDescription)
VALUES
    ('Swift Swim', 'Speed is doubled in the rain.');

--

INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Fire', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Electric', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Normal', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Psychic', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Dark', 'II');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Fairy', 'VI');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Dragon', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Steel', 'II');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Water', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Grass', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Fighting', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Poison', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Ghost', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Ground', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Ice', 'I');
INSERT INTO Type (TypeName, GenerationAdded)
VALUES
	('Flying', 'I');

--

INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Charizard', 'Flying');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Charizard', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Charmeleon', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Charmander', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Pikachu', 'Electric');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Pichu', 'Electric');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Snorlax', 'Normal');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Munchlax', 'Normal');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Jigglypuff', 'Fairy');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Jigglypuff', 'Normal');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Jirachi', 'Steel');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Jirachi', 'Psychic');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Rayquaza', 'Dragon');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Rayquaza', 'Flying');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Bulbasaur', 'Grass');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Squirtle', 'Water');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Mamoswine', 'Ice');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Mamoswine', 'Ground');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Piloswine', 'Ice');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Piloswine', 'Ground');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Swinub', 'Ice');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Swinub', 'Ground');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Greninja', 'Water');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Greninja', 'Dark');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Frogadier', 'Water');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Froakie', 'Water');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Gengar', 'Ghost');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Gengar', 'Poison');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Haunter', 'Ghost');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Haunter', 'Poison');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Gastly', 'Ghost');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Gastly', 'Poison');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Magikarp', 'Water');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Blaziken', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Blaziken', 'Fighting');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Combusken', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Combusken', 'Fighting');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Torchic', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Infernape', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Infernape', 'Fighting');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Monferno', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Monferno', 'Fighting');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Chimchar', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Emboar', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Emboar', 'Fighting');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Pignite', 'Fire');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Pignite', 'Fighting');
INSERT INTO PokemonType (SpecieName, TypeName)
VALUES
    ('Tepig', 'Fire');


--

INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Light Ball', 1);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Charizardite X', 1);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Hyper Potion', 0);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Max Potion', 0);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Potion', 0);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Full Incense', 1);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Fast Ball', 0);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Berry Juice', 0);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Leftovers', 1);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Eviolite', 1);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Focus Sash', 0);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Life Orb', 1);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Wise Glasses', 1);
INSERT INTO Item (ItemName, IsReusable)
VALUES
    ('Assault Vest', 1);

--

INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Dragon Claw', 80, 100, 15, 'Physical', 'Dragon');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Thunder Shock', 40, 100, 30, 'Special', 'Electric');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Covet', 60, 100, 25, 'Physical', 'Normal' );
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Take Down', 90, 85, 20, 'Physical', 'Normal');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Pound', 40, 100, 35, 'Physical', 'Normal');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Dragon Ascent', 120, 100, 5, 'Physical', 'Dragon');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Water Shuriken', 15, 100, 20, 'Special', 'Water');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Splash', 0, 100, 40, 'Status', 'Normal');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Sleep Talk', 0, 100, 10, 'Status', 'Normal');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Tackle', 40, 100, 35, 'Physical', 'Normal');
INSERT INTO Move (MoveName, Power, Accuracy, BasePP, Category, TypeName)
VALUES
	('Flamethrower', 90, 100, 15, 'Special', 'Fire');

--

INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(1), 'Starlight', 'U', 'Jirachi', 'Serene Grace', 'Leftovers', 65, UTL_RAW.CAST_TO_RAW(320));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(2), 'Pottry', 'F', 'Mamoswine', 'Snow Cloak', NULL, 48, UTL_RAW.CAST_TO_RAW(102));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(3), 'Thruna', 'F', 'Jigglypuff', 'Competitive', 'Eviolite', 28, UTL_RAW.CAST_TO_RAW(8));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(4), 'Shuriken to Yo Face', 'M', 'Greninja', 'Protean', 'Focus Sash', 50, UTL_RAW.CAST_TO_RAW(1));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(5), 'Super fast boii', 'U', 'Rayquaza', 'Blaze', 'Life Orb', 60, UTL_RAW.CAST_TO_RAW(1));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(6), 'Baby Fire Breathing Lizard', 'M', 'Charmander', 'Blaze', NULL, 1, UTL_RAW.CAST_TO_RAW(104));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(7), 'Medium Fire Breathing Lizard', 'M', 'Charmeleon', 'Blaze', NULL, 20, UTL_RAW.CAST_TO_RAW(104));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(8), 'Big Fire Breathing Lizard', 'M', 'Charizard', 'Blaze', NULL, 90, UTL_RAW.CAST_TO_RAW(104));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(9), 'Flower Bulb on Frog', 'F', 'Bulbasaur', 'Overgrow', NULL, 12, UTL_RAW.CAST_TO_RAW(101));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(10), 'Smol Turtle', 'M', 'Squirtle', 'Torrent', NULL, 11, UTL_RAW.CAST_TO_RAW(9999));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(11), 'Smol Turtle V2', 'F', 'Squirtle', 'Torrent', NULL, 10, UTL_RAW.CAST_TO_RAW(8));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(12), 'Smol Electric Mouse', 'M', 'Pikachu', 'Static', 'Light Ball', 18, UTL_RAW.CAST_TO_RAW(103));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(13), 'Ghostgar', 'M', 'Gengar', 'Cursed Body', 'Wise Glasses', 33, UTL_RAW.CAST_TO_RAW(1));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(14), 'Fire Ninja', 'M', 'Blaziken', 'Speed Boost', 'Life Orb', 44, UTL_RAW.CAST_TO_RAW(1));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(15), 'Sleepy Boi', 'M', 'Snorlax', 'Thick Fat', 'Assault Vest', 80, UTL_RAW.CAST_TO_RAW(7));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(16), 'Fire Guy', 'M', 'Charizard', 'Blaze', NULL, 77, UTL_RAW.CAST_TO_RAW(1));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(17), 'Most Useful Fish V1', 'F', 'Magikarp', 'Swift Swim', NULL, 75, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(18), 'Most Useful Fish V2', 'F', 'Magikarp', 'Swift Swim', NULL, 75, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(19), 'Most Useful Fish V3', 'F', 'Magikarp', 'Swift Swim', NULL, 75, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(20), 'Most Useful Fish V4', 'F', 'Magikarp', 'Swift Swim', NULL, 75, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(21), 'Most Useful Fish V5', 'F', 'Magikarp', 'Swift Swim', NULL, 75, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(22), 'Weak lil guy', 'M', 'Squirtle', 'Swift Swim', NULL, 20, UTL_RAW.CAST_TO_RAW(1));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(23), 'Testmon1', 'M', 'Squirtle', 'Swift Swim', NULL, 23, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(24), 'Testmon2', 'M', 'Pignite', 'Swift Swim', NULL, 19, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(25), 'Testmon3', 'M', 'Infernape', 'Swift Swim', NULL, 81, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(26), 'Testmon4', 'M', 'Blaziken', 'Swift Swim', NULL, 90, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(27), 'Testmon5', 'M', 'Monferno', 'Swift Swim', NULL, 23, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(28), 'Testmon6', 'M', 'Tepig', 'Swift Swim', NULL, 8, UTL_RAW.CAST_TO_RAW(105));
INSERT INTO Pokemon  (PokemonID, PokemonName, Gender, SpecieName, AbilityName, ItemName, PokemonLevel, OwnerID)
VALUES
    (UTL_RAW.CAST_TO_RAW(29), 'Testmon7', 'M', 'Pikachu', 'Swift Swim', NULL, 12, UTL_RAW.CAST_TO_RAW(1));

--

INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(1), 'Jirachi', 'Take Down');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(2), 'Mamoswine', 'Thunder Shock');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(3), 'Jigglypuff', 'Covet');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(4), 'Greninja', 'Water Shuriken');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(5), 'Rayquaza', 'Dragon Ascent');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(5), 'Rayquaza', 'Dragon Claw');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(6), 'Charmander', 'Flamethrower');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(7), 'Charmeleon', 'Flamethrower');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(8), 'Charizard', 'Flamethrower');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(8), 'Charizard', 'Splash');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(9), 'Bulbasaur', 'Tackle');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(10), 'Squirtle', 'Tackle');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(11), 'Squirtle', 'Tackle');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(12), 'Pikachu', 'Thunder Shock');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(13), 'Gengar', 'Pound');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(14), 'Blaziken', 'Flamethrower');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(15), 'Snorlax', 'Sleep Talk');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(16), 'Charizard', 'Flamethrower');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(17), 'Magikarp', 'Splash');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(18), 'Magikarp', 'Splash');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(19), 'Magikarp', 'Splash');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(20), 'Magikarp', 'Splash');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(21), 'Magikarp', 'Splash');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(23), 'Squirtle', 'Tackle');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(24), 'Pignite', 'Pound');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(25), 'Infernape', 'Flamethrower');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(26), 'Blaziken', 'Tackle');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(26), 'Blaziken', 'Flamethrower');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(26), 'Blaziken', 'Dragon Claw');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(26), 'Blaziken', 'Thunder Shock');
INSERT INTO HasMove (PokemonID, SpecieName, MoveName)
VALUES
    (UTL_RAW.CAST_TO_RAW(27), 'Monferno', 'Tackle');

--

INSERT INTO CatchableIn (SpecieName, LocationName, RegionName, GameName)
VALUES
	('Charizard', 'Route 2', 'Kanto', 'Black');
INSERT INTO CatchableIn (SpecieName, LocationName, RegionName, GameName)
VALUES
    ('Pikachu', 'Power Plant', 'Viridian Forest', 'Emerald');
INSERT INTO CatchableIn (SpecieName, LocationName, RegionName, GameName)
VALUES
    ('Rayquaza', 'Sandgem Flats', 'Hisui', 'Red');
INSERT INTO CatchableIn (SpecieName, LocationName, RegionName, GameName)
VALUES
    ('Greninja', 'Route 2', 'Kanto', 'Black');
INSERT INTO CatchableIn (SpecieName, LocationName, RegionName, GameName)
VALUES
    ('Jigglypuff', 'Route 4', 'Alola', 'Blue');

--

INSERT INTO BattlesIn (TrainerID, LocationName, RegionName, GameName)
VALUES
	(UTL_RAW.CAST_TO_RAW(101), 'Route 2', 'Kanto', 'Black');
INSERT INTO BattlesIn (TrainerID, LocationName, RegionName, GameName)
VALUES
	(UTL_RAW.CAST_TO_RAW(102), 'Power Plant', 'Viridian Forest', 'Emerald');
INSERT INTO BattlesIn (TrainerID, LocationName, RegionName, GameName)
VALUES
	(UTL_RAW.CAST_TO_RAW(103), 'Sandgem Flats', 'Hisui', 'Red');
INSERT INTO BattlesIn (TrainerID, LocationName, RegionName, GameName)
VALUES
	(UTL_RAW.CAST_TO_RAW(104), 'Route 4', 'Alola', 'Blue');
INSERT INTO BattlesIn (TrainerID, LocationName, RegionName, GameName)
VALUES
	(UTL_RAW.CAST_TO_RAW(105), 'Route 2', 'Kanto', 'Black');

--

INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(301), UTL_RAW.CAST_TO_RAW(9), 'Bulbasaur');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(302), UTL_RAW.CAST_TO_RAW(2), 'Mamoswine');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(303), UTL_RAW.CAST_TO_RAW(12), 'Pikachu');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(304), UTL_RAW.CAST_TO_RAW(6), 'Charmander');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(304), UTL_RAW.CAST_TO_RAW(7), 'Charmeleon');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(304), UTL_RAW.CAST_TO_RAW(8), 'Charizard');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(305), UTL_RAW.CAST_TO_RAW(17), 'Magikarp');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(305), UTL_RAW.CAST_TO_RAW(18), 'Magikarp');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(305), UTL_RAW.CAST_TO_RAW(19), 'Magikarp');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(305), UTL_RAW.CAST_TO_RAW(20), 'Magikarp');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(305), UTL_RAW.CAST_TO_RAW(21), 'Magikarp');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(306), UTL_RAW.CAST_TO_RAW(23), 'Squirtle');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(307), UTL_RAW.CAST_TO_RAW(28), 'Tepig');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(308), UTL_RAW.CAST_TO_RAW(27), 'Monferno');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(308), UTL_RAW.CAST_TO_RAW(26), 'Blaziken');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(309), UTL_RAW.CAST_TO_RAW(25), 'Infernape');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(309), UTL_RAW.CAST_TO_RAW(24), 'Pignite');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(309), UTL_RAW.CAST_TO_RAW(28), 'Tepig');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(310), UTL_RAW.CAST_TO_RAW(25), 'Infernape');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(311), UTL_RAW.CAST_TO_RAW(26), 'Blaziken');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(311), UTL_RAW.CAST_TO_RAW(25), 'Infernape');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(1), UTL_RAW.CAST_TO_RAW(4), 'Greninja');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(1), UTL_RAW.CAST_TO_RAW(5), 'Rayquaza');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(1), UTL_RAW.CAST_TO_RAW(13), 'Gengar');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(1), UTL_RAW.CAST_TO_RAW(14), 'Blaziken');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(1), UTL_RAW.CAST_TO_RAW(16), 'Charizard');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(1), UTL_RAW.CAST_TO_RAW(29), 'Pikachu');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(2), UTL_RAW.CAST_TO_RAW(22), 'Squirtle');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(3), UTL_RAW.CAST_TO_RAW(29), 'Pikachu');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(4), UTL_RAW.CAST_TO_RAW(13), 'Gengar');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(5), UTL_RAW.CAST_TO_RAW(29), 'Pikachu');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(5), UTL_RAW.CAST_TO_RAW(22), 'Squirtle');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(402), UTL_RAW.CAST_TO_RAW(10), 'Squirtle');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(403), UTL_RAW.CAST_TO_RAW(3), 'Jigglypuff');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(403), UTL_RAW.CAST_TO_RAW(11), 'Squirtle');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(404), UTL_RAW.CAST_TO_RAW(15), 'Snorlax');
INSERT INTO BelongsTo (TeamID, PokemonID, SpecieName)
VALUES
	(UTL_RAW.CAST_TO_RAW(405), UTL_RAW.CAST_TO_RAW(1), 'Jirachi');

--

INSERT INTO FoundIn (ItemName, LocationName, RegionName, GameName)
VALUES
    ('Light Ball', 'Route 2', 'Kanto', 'White');
INSERT INTO FoundIn (ItemName, LocationName, RegionName, GameName)
VALUES
    ('Charizardite X', 'Route 4', 'Alola', 'Violet');
INSERT INTO FoundIn (ItemName, LocationName, RegionName, GameName)
VALUES
    ('Full Incense', 'Power Plant', 'Viridian Forest', 'Sun');
INSERT INTO FoundIn (ItemName, LocationName, RegionName, GameName)
VALUES
    ('Fast Ball', 'Route 2', 'Kanto', 'Scarlet');
INSERT INTO FoundIn (ItemName, LocationName, RegionName, GameName)
VALUES
    ('Berry Juice', 'Route 4', 'Alola', 'Emerald');