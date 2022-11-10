#!/bin/bash                 

scw instance server create type=PLAY2-PICO zone=fr-par-1 image=ubuntu_jammy root-volume=b:10G additional-volumes.0=b:10G name=Roro-toDelete ip=new project-id=f7cfc317-a399-4804-b3bf-9e55f4ce842c
