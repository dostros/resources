local QBCore = exports['qb-core']:GetCoreObject()



CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `ems_patients` (
            `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
            `nom` VARCHAR(50),
            `prenom` VARCHAR(50),
            `age` INT,
            `sexe` VARCHAR(10),
            `maladie` VARCHAR(100),
            `remarques` TEXT
        );
    ]], {}, function()
    end)
end)



-- Insertion en base
QBCore.Functions.CreateCallback("ems:addPatientToDatabase", function(source, cb, data)
    print("2")
    MySQL.query('INSERT INTO ems_patients (nom, prenom, age, sexe, maladie, remarques) VALUES (@nom, @prenom, @age, @sexe, @maladie, @remarques)', {
        ['@nom'] = data.nom,
        ['@prenom'] = data.prenom,
        ['@age'] = data.age,
        ['@sexe'] = data.sexe,
        ['@maladie'] = data.maladie,
        ['@remarques'] = data.remarques
    }, function(result)
        print("3")
        -- Ici on retourne true si tout s'est bien passé
        cb(true)
    end)
end)


-- Récupération via callback
QBCore.Functions.CreateCallback("ems:getPatientsFromDatabase", function(source, cb)
    MySQL.query('SELECT * FROM ems_patients', {}, function(result)
        cb(result)
    end)
end)


QBCore.Functions.CreateCallback("ems:updatePatientInDatabase", function(source, cb, data)
    MySQL.query('UPDATE ems_patients SET nom = @nom, prenom = @prenom, age = @age, sexe = @sexe, maladie = @maladie, remarques = @remarques WHERE id = @id', {
        ['@id'] = data.id,
        ['@nom'] = data.nom,
        ['@prenom'] = data.prenom,
        ['@age'] = data.age,
        ['@sexe'] = data.sexe,
        ['@maladie'] = data.maladie,
        ['@remarques'] = data.remarques
    }, function()
        cb(true)
    end)
end)


QBCore.Functions.CreateCallback("ems:deletePatientFromDatabase", function(source, cb, data)
    MySQL.query('DELETE FROM ems_patients WHERE id = @id', {
        ['@id'] = data.id
    }, function()
        cb(true)
    end)
end)
