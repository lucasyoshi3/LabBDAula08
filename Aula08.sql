CREATE DATABASE Campeonato

CREATE TABLE Tabela_times(
	Cod_Time				INT,
	Nome_Time				VARCHAR(50)
	PRIMARY KEY(Cod_Time)
)

CREATE TABLE Jogos(
	Cod_Time_A				INT,
	Cod_Time_B				INT,
	Set_Time_A				INT,
	Set_Time_B				INT
	FOREIGN KEY(Cod_Time_A) REFERENCES Tabela_times(Cod_Time),
	FOREIGN KEY(Cod_Time_B) REFERENCES Tabela_times(Cod_Time) 
)

CREATE FUNCTION f_tabela(@cod_time INT)
RETURNS @table TABLE(
	NomeTime			VARCHAR(50),
	TotalPontos			INT,
	TotalSetsGanhos		INT,
	TotalSetsPerdidos	INT,
	SetAverage			INT
)
AS
	BEGIN
		INSERT INTO @table(NomeTime) 
		SELECT Nome_Time FROM Tabela_times WHERE Cod_Time = @cod_time;

		DECLARE @pontos INT = 0
		DECLARE @ganhos INT = 0
		DECLARE @perdidos INT = 0

		SELECT 
			@ganhos = @ganhos + CASE 
				WHEN Cod_Time_A = @cod_time AND Set_Time_A = 3 THEN 3
				WHEN Cod_Time_A = @cod_time AND Set_Time_A = 2 THEN 2
				WHEN Cod_Time_B = @cod_time AND Set_Time_B = 3 THEN 3
				WHEN Cod_Time_B = @cod_time AND Set_Time_B = 2 THEN 2
			END,
			@perdidos = @perdidos + CASE 
				WHEN Cod_Time_A = @cod_time AND Set_Time_A = 3 THEN 3
				WHEN Cod_Time_A = @cod_time AND Set_Time_A = 2 THEN 2
				WHEN Cod_Time_B = @cod_time AND Set_Time_B = 3 THEN 3
				WHEN Cod_Time_B = @cod_time AND Set_Time_B = 2 THEN 2
			END,
			@pontos = @pontos + CASE 
				WHEN Cod_Time_A = @cod_time AND Set_Time_A = 3 THEN 
					CASE WHEN (Set_Time_A = 3 AND Set_Time_B = 0) OR (Set_Time_A = 3 AND Set_Time_B = 1) THEN 3 ELSE 2 END
				WHEN Cod_Time_B = @cod_time AND Set_Time_B = 3 THEN 
					CASE WHEN (Set_Time_B = 3 AND Set_Time_A = 0) OR (Set_Time_B = 3 AND Set_Time_A = 1) THEN 3 ELSE 2 END
				ELSE 0
			END
		FROM Jogos
		WHERE Cod_Time_A = @cod_time OR Cod_Time_B = @cod_time

		UPDATE @table
		SET 
			TotalPontos = @pontos,
			TotalSetsGanhos = @ganhos,
			TotalSetsPerdidos = @perdidos,
			SetAverage = @ganhos - @perdidos;

		RETURN
	END
	

CREATE TRIGGER t_contagem_pontos ON Jogos 
FOR INSERT
AS
	BEGIN
			
		IF((SELECT Set_Time_A FROM inserted) > 3 OR (SELECT Set_Time_B FROM inserted) > 3)
		BEGIN 
			RAISERROR('Set Não Pode Ser Maior Que 3',16,1)
			ROLLBACK TRANSACTION
		END
		
		IF((SELECT Set_Time_A FROM inserted) + (SELECT Set_Time_B FROM inserted) > 5)
		BEGIN
			RAISERROR('A Contagem De Sets Não Pode Ser Maior Que 5',16,1)
			ROLLBACK TRANSACTION
		END

	END

INSERT INTO Tabela_times VALUES(1, 'Time A')
INSERT INTO Tabela_times VALUES(2, 'Time B')
INSERT INTO Tabela_times VALUES(3, 'Time C')
INSERT INTO Tabela_times VALUES(4, 'Time D')

INSERT INTO Jogos VALUES 
(1,2,3,1),
(1,3,3,0),
(1,4,1,3),
(2,3,1,3),
(2,4,3,0),
(3,4,3,1)

INSERT INTO Jogos VALUES 
(1,2,4,1)

SELECT *FROM Jogos
DELETE FROM Jogos
--Este é um comentário


