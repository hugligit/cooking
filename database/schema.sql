-- {{{ INITIAL CLEANUP
DROP TABLE IF EXISTS bridge_meals_ingredients;
DROP TABLE IF EXISTS meals;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS units;
-- }}}
-- {{{ CREATE TABLES
--{{{ meals
CREATE TABLE meals (
    meal_id          INTEGER   PRIMARY KEY       ,
    name             TEXT                        ,
    portions         INTEGER   DEFAULT 1
    );
-- }}}
--{{{ ingredients
CREATE TABLE ingredients (
    ingredient_id    INTEGER   PRIMARY KEY       ,
    name             TEXT                        ,
    unit_id          INTEGER   REFERENCES units  ,
    amount           INTEGER                     ,
    price            INTEGER
    );
-- }}}
--{{{ units
CREATE TABLE units (
    unit_id          INTEGER   PRIMARY KEY       ,
    name             TEXT
    );
-- }}}
--{{{ bridge_meals_ingredients
CREATE TABLE bridge_meals_ingredients (
    meal_id    INTEGER         ,
    ingredient_id INTEGER,
    amount        INTEGER,
    FOREIGN KEY (meal_id) REFERENCES meals (meal_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (ingredient_id)
);
-- }}}
-- }}}
-- {{{ IMPORT DATA
.mode csv
.import units.csv tmp
INSERT INTO units (name) SELECT name FROM tmp;
DROP TABLE tmp;

.import meals.csv tmp
INSERT INTO meals (name) SELECT name FROM tmp;
DROP TABLE tmp;

.import ingredients.csv tmp
INSERT INTO ingredients (name, unit_id, amount, price) SELECT name, unit_id, amount, price FROM tmp;
DROP TABLE tmp;

.import bridge.csv tmp
INSERT INTO bridge_meals_ingredients (meal_id, ingredient_id, amount) SELECT meal_id, ingredient_id, amount  FROM tmp;
DROP TABLE tmp;

-- }}}
-- {{{ SQLITE3 ENVIRONMENT
.mode column
.headers on
-- }}}
-- {{{ TESTS
-- SELECT * FROM meals LIMIT 10;
-- SELECT * FROM ingredients LIMIT 10;

SELECT
    meals.name AS NAME,
    sum((price * bridge_meals_ingredients.amount)/ingredients.amount) AS PRICE
    FROM
        bridge_meals_ingredients
    JOIN meals USING (meal_id)
    JOIN ingredients USING (ingredient_id)
    GROUP BY meal_id
;



-- }}}
