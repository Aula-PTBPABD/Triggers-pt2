CREATE TRIGGER dbo.trigger_prevent_assignment_teaches
ON teaches
INSTEAD OF INSERT
AS
BEGIN
    /*Verifica se o instrutor já tem 2 atribuições no ano inserido pelo usuário*/
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN (
            SELECT ID, year, COUNT(*) AS num_atribuicoes
            FROM teaches
            GROUP BY ID, year
        ) t ON i.ID = t.ID AND i.year = t.year
        WHERE t.num_atribuicoes >= 2
    )
    BEGIN
        RAISERROR('Esse instrutor já possui 2 ou mais atribuições no mesmo ano.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    /*Se passar pela verificação, realiza o insert normalmente*/
    INSERT INTO teaches (ID, course_id, sec_id, semester, year)
    SELECT ID, course_id, sec_id, semester, year
    FROM inserted;
END;

