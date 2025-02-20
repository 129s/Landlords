@echo off
title Landlords Debug Console

:: 启动玩家1（地主视角）
start "Player 1 - Landlord" flutter run -d chrome --web-port=8080 --dart-define=PLAYER_NAME=Player1

:: 启动玩家2（农民视角） 
start "Player 2 - Farmer" flutter run -d chrome --web-port=8081 --dart-define=PLAYER_NAME=Player2

:: 启动玩家3（农民视角）
start "Player 3 - Farmer" flutter run -d chrome --web-port=8082 --dart-define=PLAYER_NAME=Player3