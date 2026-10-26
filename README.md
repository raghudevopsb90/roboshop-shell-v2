# RoboShop Shell

Shell scripts to set up RoboShop microservices, one component per server (RHEL 10, practice AMI).

## Before you run

- Create one server per component and a DNS record `<component>.rdevopsb90.online` pointing to its **private IP**.
- Copy this folder to each server.

## Run

On each server, run its own script as root, in this order:

```shell
cd roboshop-shell
sudo bash 01-frontend.sh      # on frontend server
sudo bash 02-mysql.sh         # on mysql server
sudo bash 03-catalogue.sh     # on catalogue server
sudo bash 04-mongodb.sh
sudo bash 05-user.sh
sudo bash 06-valkey.sh
sudo bash 07-cart.sh
sudo bash 08-shipping.sh
sudo bash 09-rabbitmq.sh
sudo bash 10-payment.sh
sudo bash 11-notification.sh
sudo bash 12-orders.sh
sudo bash 13-ratings.sh
```

Each step prints SUCCESS or FAILURE. On failure the script stops; details are in `/tmp/roboshop.log`.
Scripts are safe to run again.

Open `http://<frontend-public-ip>` in the browser.
