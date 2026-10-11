#!/usr/bin/env python3
"""Aplica permissões e deployment targets necessários aos wrappers Flutter."""
from pathlib import Path
import plistlib
import re

ROOT = Path(__file__).resolve().parents[1]

# Android: só permissões locais necessárias à câmara e ao ditado.
manifest = ROOT / 'android/app/src/main/AndroidManifest.xml'
if manifest.exists():
    text = manifest.read_text(encoding='utf-8')
    for permission in ('android.permission.CAMERA', 'android.permission.RECORD_AUDIO'):
        tag = f'<uses-permission android:name="{permission}" />'
        if permission not in text:
            text = re.sub(r'(<manifest\b[^>]*>)', r'\1\n    ' + tag, text, count=1)
    text = re.sub(r'android:label="[^"]*"', 'android:label="EA LANGUAGE HUB"', text, count=1)
    manifest.write_text(text, encoding='utf-8')

# iOS: Google ML Kit e captura de imagem/voz requerem target e textos de consentimento.
info = ROOT / 'ios/Runner/Info.plist'
if info.exists():
    with info.open('rb') as file:
        data = plistlib.load(file)
    data.update({
        'CFBundleDisplayName': 'EA LANGUAGE HUB',
        'NSCameraUsageDescription': 'A câmara é usada para ler texto de imagens com OCR no dispositivo.',
        'NSPhotoLibraryUsageDescription': 'Escolha uma imagem para extrair texto localmente.',
        'NSMicrophoneUsageDescription': 'O microfone é usado quando inicia o ditado por voz.',
        'NSSpeechRecognitionUsageDescription': 'O reconhecimento de voz converte o seu ditado em texto.',
    })
    with info.open('wb') as file:
        plistlib.dump(data, file, fmt=plistlib.FMT_XML, sort_keys=False)

podfile = ROOT / 'ios/Podfile'
if podfile.exists():
    text = podfile.read_text(encoding='utf-8')
    if re.search(r'^\s*platform :ios,', text, flags=re.MULTILINE):
        text = re.sub(r'^\s*platform :ios,\s*[\'\"][^\'\"]+[\'\"]', "platform :ios, '15.5'", text, count=1, flags=re.MULTILINE)
    else:
        text = "platform :ios, '15.5'\n" + text
    if "installer.pods_project.build_configurations.each" not in text:
        text = text.replace(
            'post_install do |installer|',
            "post_install do |installer|\n"
            "  installer.pods_project.build_configurations.each do |config|\n"
            "    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.5'\n"
            "    config.build_settings['EXCLUDED_ARCHS[sdk=*]'] = 'armv7'\n"
            "  end",
        )
    if 'target.build_configurations.each do |config|' not in text:
        text = text.replace(
            'flutter_additional_ios_build_settings(target)',
            "flutter_additional_ios_build_settings(target)\n"
            "    target.build_configurations.each do |config|\n"
            "      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.5'\n"
            "    end",
        )
    podfile.write_text(text, encoding='utf-8')

project = ROOT / 'ios/Runner.xcodeproj/project.pbxproj'
if project.exists():
    text = project.read_text(encoding='utf-8')
    text = re.sub(r'IPHONEOS_DEPLOYMENT_TARGET = [^;]+;', 'IPHONEOS_DEPLOYMENT_TARGET = 15.5;', text)
    project.write_text(text, encoding='utf-8')

# Android target SDKs are supplied by the current Flutter Gradle plugin.
# Keep minSdk >= 21 for the on-device ML Kit text recognizer.
for gradle in (ROOT / 'android/app/build.gradle', ROOT / 'android/app/build.gradle.kts'):
    if not gradle.exists():
        continue
    text = gradle.read_text(encoding='utf-8')
    text = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 21', text)
    text = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 21', text)
    gradle.write_text(text, encoding='utf-8')

print('Configuração Android/iOS aplicada (permissões, nomes e deployment target).')
