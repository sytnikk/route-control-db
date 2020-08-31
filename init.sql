CREATE TABLE IF NOT EXISTS transport_type (
    id INT NOT NULL AUTO_INCREMENT,
    text VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS car_status (
    id INT NOT NULL AUTO_INCREMENT,
    text VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS route_status (
    id INT NOT NULL AUTO_INCREMENT,
    text VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS car (
  id INT NOT NULL AUTO_INCREMENT,
  licensePlate VARCHAR(255) NOT NULL,
  model VARCHAR(255) NOT NULL,
  transportTypeId INT NOT NULL,
  purchaseDate DATE NOT NULL,
  mileage INT NOT NULL,
  carStatusId INT NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  FOREIGN KEY (transportTypeId) REFERENCES transport_type (id),
  FOREIGN KEY (carStatusId) REFERENCES car_status (id)
);

CREATE TABLE IF NOT EXISTS route (
  id INT NOT NULL AUTO_INCREMENT,
  cityStart VARCHAR(255) NOT NULL,
  cityEnd VARCHAR(255) NOT NULL,
  revenue INT NOT NULL,
  distanceBetweenCities INT NOT NULL,
  sendingDate DATE NOT NULL,
  transportTypeId INT,
  carId INT,
  routeStatusId INT NOT NULL DEFAULT 1,
  deliveryDate DATE NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (transportTypeId) REFERENCES transport_type (id),
  FOREIGN KEY (carId) REFERENCES car (id),
  FOREIGN KEY (routeStatusId) REFERENCES route_status (id)
);

INSERT INTO transport_type (text) VALUES ('Грузовой');
INSERT INTO transport_type (text) VALUES ('Легковой');

INSERT INTO car_status(text) VALUES ('Свободен');
INSERT INTO car_status(text) VALUES ('Занят');

INSERT INTO route_status(text) VALUES ('Ожидает отправки');
INSERT INTO route_status(text) VALUES ('Выполняется');
INSERT INTO route_status(text) VALUES ('Выполнен');

INSERT INTO car (licensePlate, model, transportTypeId, purchaseDate, mileage, carStatusId) VALUES ('АА0001КВ', 'Ford Focus', 2, '2020-02-29', 72434, 1);
INSERT INTO car (licensePlate, model, transportTypeId, purchaseDate, mileage, carStatusId) VALUES ('АА4200ВВ', 'DAF XF 105', 1, '2010-05-19', 23434, 2);
INSERT INTO car (licensePlate, model, transportTypeId, purchaseDate, mileage, carStatusId) VALUES ('АА3220ВВ', 'Scania R420', 1, '2020-02-29', 356764, 1);

INSERT INTO route (cityStart, cityEnd, distanceBetweenCities, sendingDate, transportTypeId, carId, routeStatusId, deliveryDate, revenue) VALUES ('Kyiv', 'Odessa', 753, '2020-08-29', 2, 1, 2, '2020-08-30', 2000);
INSERT INTO route (cityStart, cityEnd, distanceBetweenCities, sendingDate, transportTypeId, carId, routeStatusId, deliveryDate, revenue) VALUES ('Kyiv', 'Lviv', 753, '2020-08-29', 1, 2, 1, '2020-08-30', 2000);

ALTER USER 'test'@'%' IDENTIFIED WITH mysql_native_password BY 'test';
flush privileges;

CREATE EVENT IF NOT EXISTS update_car_statuses
    ON SCHEDULE EVERY 1 DAY STARTS '2020-08-13 00:00:00'
    ON COMPLETION PRESERVE ENABLE
    DO
    UPDATE car
        INNER JOIN route  ON route.carId = car.id
    SET
        carStatusId = IF(CURRENT_TIME() > sendingDate AND CURRENT_TIME() < deliveryDate, 2, 1),
        routeStatusId = IF(
            CURRENT_TIME() > sendingDate AND CURRENT_TIME() < deliveryDate, 2,
                IF (
                    CURRENT_TIME() > sendingDate AND CURRENT_TIME() > deliveryDate, 3, 1
                )
            );
