#!/usr/bin/python3

import os
import sys
import json

from flask import Flask, request, redirect, url_for, send_from_directory, session, render_template
app = Flask(__name__)
app.secret_key = "changeit"
app.debug = True

#-----------------------------
scriptDir = os.path.dirname(os.path.realpath(__file__))
picsDir = scriptDir + '/static/pics'
allowedFileEndings = [".png", ".jpg", ".jpeg", ".gif"]
#-----------------------------

#-------------------------------------------------------------------------

@app.route('/', methods=['GET']) 
def root():
    return redirect("/0", code=302)

#----------------------------------------

@app.route('/<picId>', methods=['GET']) 
def pic_show(picId):
    picId = int(picId)

    picsTmpAry = os.listdir(picsDir)
    picAry = []
    for fileName in picsTmpAry:
        for ending in allowedFileEndings:
            if fileName.endswith(ending):
                picAry.append(fileName)
    #print(picAry)

    try:
        picPath = '/static/pics/' + picAry[picId]
        #print(picPath)
    except:
        return redirect("/0", code=302)

    if picId == len(picAry):
        nextId = 0
    else:
        nextId = picId + 1
    
    if picId == 0:
        prevId = len(picAry) - 1
    else:
        prevId = picId - 1

    return render_template('pics.html', 
        view='base', 
        picId=picId,
        nextId=nextId,
        prevId=prevId,
        picPath=picPath
    )


#-------------------------------------------------------------------------

if __name__ == '__main__':
    app.run(host='0.0.0.0')

#-------------------------------------------------------------------------