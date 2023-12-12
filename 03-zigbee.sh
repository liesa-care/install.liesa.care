#!/bin/bash

#
# Setup for zigbee.
#

echo "Add user to dialout group."
sudo adduser $USER dialout

echo "Install node from snap."
sudo snap install node --classic

echo "Install mosquitto."
sudo apt install -y mosquitto mosquitto-clients

echo "Allow mosquitto access from LAN."
sudo tee /etc/mosquitto/conf.d/liesa-care.conf << EOF
listener 1883 0.0.0.0
allow_anonymous true
EOF

echo "Make zigbee2mqtt directory."
sudo mkdir /opt/zigbee2mqtt
sudo chown -R ${USER}: /opt/zigbee2mqtt

echo "Install zigbee2mqtt."
git clone --depth 1 https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt

echo "Compile zigbee2mqtt."
cd /opt/zigbee2mqtt
npm ci
npm run build

echo "Create config."
tee /opt/zigbee2mqtt/data/configuration.yaml << EOF
homeassistant: false

frontend:
  port: 4780

mqtt:
  base_topic: zigbee2mqtt
  server: 'mqtt://localhost'

serial:
  port: /dev/ttyUSB0

advanced:
  network_key: GENERATE
  pan_id: GENERATE
  ext_pan_id: GENERATE
EOF

echo "Create start script."
tee /opt/zigbee2mqtt/zigbee2mqtt << EOF
#!/bin/bash
cd /opt/zigbee2mqtt
npm start > /dev/null 2>&1
EOF

chmod a+x /opt/zigbee2mqtt/zigbee2mqtt
