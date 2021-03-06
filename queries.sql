/*Queries that provide answers to the questions from all projects.*/

/* Find all animals whose name ends in "mon".*/
SELECT * FROM animals WHERE name LIKE '%mon'; 

/* List the name of all animals born between 2016 and 2019.*/
SELECT name FROM animals WHERE date_of_birth BETWEEN '2016-01-10' AND '2019-01-01'; 

/* List the name of all animals that are neutered and have less than 3 escape attempts.*/
SELECT name FROM animals WHERE neutered='1' AND escape_attempts < 3; 

/* List date of birth of all animals named either "Agumon" or "Pikachu".*/
SELECT date_of_birth from animals WHERE name='Agumon' OR name ='Pikachu'; 

 /* List name and escape attempts of animals that weigh more than 10.5kg */
SELECT name,escape_attempts FROM animals WHERE weight_kg > 10.5;

/* Find all animals that are neutered.*/
SELECT * FROM animals WHERE neutered ='1'; 

/* Find all animals not named Gabumon.*/
SELECT * FROM animals WHERE  NOT name='Gabumon'; 

/* Find all animals with a weight between 10.4kg and 17.3kg (including the animals with the weights that equals precisely 10.4kg or 17.3kg)*/
SELECT * FROM animals WHERE weight_kg >= 10.4 AND weight_kg <=17.3; 


-- Task Two
/*
Inside a transaction update the animals table by setting the species column to unspecified. Verify that change was made. Then roll back the change and verify that species columns went back to the state before transaction.
*/
BEGIN;
UPDATE animals set species='unspecified';
SELECT * FROM animals;
ROLLBACK;


/* 
    Inside a transaction:
        Update the animals table by setting the species column to digimon for all animals that have a name ending in mon.
        Update the animals table by setting the species column to pokemon for all animals that don't have species already set.
        Commit the transaction.
    Verify that change was made and persists after commit.
*/

BEGIN;
UPDATE animals SET species='digimon' WHERE name LIKE '%mon';
UPDATE animals SET species='pokemon' WHERE species IS NULL;
COMMIT;


/*
Now, take a deep breath and... Inside a transaction delete all records in the animals table, then roll back the transaction.
*/
BEGIN;
TRUNCATE animals;
DELETE FROM animals;
SELECT * FROM animals; /* Cehck Whether table is now Empty*/
ROLLBACK;

/*
    Inside a transaction:
        Delete all animals born after Jan 1st, 2022.
        Create a savepoint for the transaction.
        Update all animals' weight to be their weight multiplied by -1.
        Rollback to the savepoint
        Update all animals' weights that are negative to be their weight multiplied by -1.
        Commit transaction
*/

BEGIN;
DELETE FROM animals WHERE date_of_birth > '2022-01-01';
SAVEPOINT born_befor_2022;
UPDATE animals SET weight_kg = (weight_kg * -1);
ROLLBACK TO born_befor_2022;
SELECT  * FROM animals; /* Verify data state */
COMMIT;

/* How many animals are there?*/
SELECT COUNT(*)  FROM animals; 

/* How many animals have never tried to escape?*/
SELECT COUNT(*)  FROM animals WHERE escape_attempts > 0; 

/* What is the average weight of animals?*/
SELECT AVG(weight_kg) FROM animals; 

 /* Who escapes the most, neutered or not neutered animals?*/
SELECT MAX(escape_attempts) FROM animals WHERE (neutered='1') OR (neutered ='0');

/* What is the minimum and maximum weight of each type of animal?*/
SELECT species,MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY species; 

/* What is the average number of escape attempts per animal type of those born between 1990 and 2000?*/
SELECT species, AVG(escape_attempts) FROM animals WHERE date_of_birth > '1990-01-01' AND date_of_birth < '2000-01-01' GROUP BY species;

-- Task 3

/* What animals belong to Melody Pond?*/
SELECT name FROM animals
  LEFT JOIN owners ON animals.owner_id = owners.id
WHERE full_name = 'Melody Pond';


-- List of all animals that are pokemon (their type is Pokemon).
SELECT animals.name
  FROM animals
  LEFT JOIN species ON animals.species_id = species.id
WHERE species.name = 'Pokemon';


-- List all owners and their animals, remember to include those that don't own any animal.
SELECT full_name, name
  FROM animals
  FULL JOIN owners ON animals.owner_id = owners.id;


-- How many animals are there per species?
SELECT species.name,
  COUNT(*)
  FROM animals
  LEFT JOIN species ON animals.species_id = species.id
  GROUP BY species.name;


-- List all Digimon owned by Jennifer Orwell.
SELECT animals.name
  FROM animals
  LEFT JOIN species ON animals.species_id = species.id
  LEFT  JOIN owners ON owner_id = owners.id
WHERE species.name = 'Digimon' AND full_name = 'Jennifer Orwell';


-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT name
  FROM animals
  LEFT JOIN owners ON owner_id = owners.id
WHERE full_name = 'Dean Winchester' AND escape_attempts = 0;

-- Who owns the most animals?
SELECT full_name,
  COUNT(*)
  FROM animals
  LEFT JOIN owners ON owner_id = owners.id
GROUP BY full_name
ORDER BY COUNT(*) DESC
LIMIT 1;


-- Who was the last animal seen by William Tatcher?
SELECT animals.name, visits.date
  FROM visits
  JOIN animals ON animals.id = animals_id
  JOIN vets ON vets.id = vets_id
WHERE vets.name = 'William Tatcher'
GROUP BY visits.date, animals.name
ORDER BY visits.date DESC
LIMIT 1;

-- How many different animals did Stephanie Mendez see?
SELECT COUNT(*) FROM visits
  JOIN animals ON animals.id = animals_id
  JOIN vets ON vets.id = vets_id
WHERE vets.name = 'Stephanie Mendez';

-- List all vets and their specialties, including vets with no specialties.
SELECT vets.name AS vet_names, species.name AS specialty
  FROM specializations
  FULL JOIN vets ON vets_id = vets.id
  FULL JOIN species ON species_id = species.id;

-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT animals.name, visits.date
  FROM visits
  JOIN animals ON animals.id = animals_id
  JOIN vets ON vets.id = vets_id
WHERE vets.name = 'Stephanie Mendez' AND date BETWEEN '2020-04-01' AND '2020-08-30'
GROUP BY visits.date, animals.name
ORDER BY visits.date DESC;

-- What animal has the most visits to vets?
SELECT animals.name, COUNT(*) AS visits FROM visits
  JOIN animals ON animals.id = animals_id
GROUP BY animals.name
ORDER BY visits DESC
LIMIT 1;

-- Who was Maisy Smith's first visit?
SELECT animals.name, owners.full_name AS owner, visits.date
  FROM visits
  JOIN animals ON animals.id = animals_id
  JOIN vets ON vets.id = vets_id
  JOIN owners ON animals.owner_id = owners.id
WHERE vets.name = 'Maisy Smith'
GROUP BY visits.date, animals.name, owners.full_name
ORDER BY visits.date ASC
LIMIT 1;

-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT * FROM visits
  JOIN animals ON animals.id = animals_id
ORDER BY visits.date ASC;

-- How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(*) FROM visits
  JOIN animals ON animals.id = animals_id
  JOIN vets ON vets.id = vets_id
  JOIN owners ON animals.owner_id = owners.id
  JOIN specializations ON vets.id = specializations.vets_id
WHERE specializations.species_id != animals.species_id;

-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT species.name, COUNT(*) FROM visits
  JOIN animals ON animals.id = animals_id
  JOIN vets ON vets.id = vets_id
  JOIN species ON animals.species_id = species.id
WHERE vets.name = 'Maisy Smith'
GROUP BY species.name
ORDER BY COUNT(*) DESC
LIMIT 1;

