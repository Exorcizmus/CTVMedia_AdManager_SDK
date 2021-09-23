This project contains a set of SDKs of advertising video player for embedding into games and other ROKU channels (Scenegraph).
As well as a simple example of its call. 

How to start
This information describes how to embed this SDK on your Roku scenegraph channel, and then how to start using it. 

1. Copy the RokuPlayer folder from this example into your "Components" folder.
2. Add a Rokuplayer node with id="Rokuplayer" to your group/scene in the children section. It can be any component you like.
3. In the brightscript code section, find the Rokuplayer node. Specify settings such as the name of your advertising channel in our system (channelName), the name of your product/game (appName), the id of your bundle (appBundleId) if any. 
4. Optional: To make our component show the logos of your games/products. Replace the files inside the "GameLogos" folder (not more than 99 files) and specify the number of logos in the "countGames" variable in the playerSDK setup.
5. Warning: By default, there can only be one active sound source at a time. Therefore, to show video ads with sound, you need to turn off the background music in the game at the moment of showing video ads and set the "muteAdVideo" parameter to "false". This can be done on the fly, not during player initialization.
6. Optional: If there are errors in the player's operation or if you want to see a log with information about the operation, set the "debug" parameter to true.
7. The moment you need to start showing ads to your users call the "startWork" function. (For example: m.rokuPlayer.callFunc("startWork"))
8. You can see an example of the implementation in the files: MainScene.xml and MainScene.brs
