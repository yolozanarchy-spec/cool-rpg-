from lxml import etree
from pathlib import Path
root_dir=Path(__file__).parent
root=etree.Element('roblox',version='4')
for value in ('null','nil'):
 etree.SubElement(root,'External').text=value
n=0
def item(parent,cls,name,source=None):
 global n
 n+=1
 obj=etree.SubElement(parent,'Item',{'class':cls,'referent':f'RBX{n:08d}'})
 props=etree.SubElement(obj,'Properties')
 etree.SubElement(props,'string',name='Name').text=name
 if source is not None: etree.SubElement(props,'ProtectedString',name='Source').text=etree.CDATA(source)
 return obj,props
def flag(p,name,value): etree.SubElement(p,'bool',name=name).text='true' if value else 'false'
def numeric(p,name,value): etree.SubElement(p,'float',name=name).text=str(value)
def vector(p,name,v):
 q=etree.SubElement(p,'Vector3',name=name)
 for k,x in zip('XYZ',v): etree.SubElement(q,k).text=str(x)
def color(p,name,v):
 q=etree.SubElement(p,'Color3',name=name)
 for k,x in zip('RGB',v): etree.SubElement(q,k).text=str(x)
def frame(p,name,pos):
 q=etree.SubElement(p,'CoordinateFrame',name=name)
 for k,v in zip(('X','Y','Z'),pos):etree.SubElement(q,k).text=str(v)
 for k,v in zip(('R00','R01','R02','R10','R11','R12','R20','R21','R22'),(1,0,0,0,1,0,0,0,1)):etree.SubElement(q,k).text=str(v)
w,_=item(root,'Workspace','Workspace')
platform,p=item(w,'Part','Dark Fantasy Base')
flag(p,'Anchored',True);flag(p,'CanCollide',True);vector(p,'Size',(120,1,120));frame(p,'CFrame',(0,-1,0));color(p,'Color',(0.10,0.12,0.16))
spawn,p=item(w,'SpawnLocation','Start Spawn')
flag(p,'Anchored',True);flag(p,'Neutral',True);vector(p,'Size',(8,1,8));frame(p,'CFrame',(0,1,0));color(p,'Color',(0.39,0.31,0.54));numeric(p,'Transparency',.1)
repl,_=item(root,'ReplicatedStorage','ReplicatedStorage')
shared,_=item(repl,'Folder','Shared')
for file in sorted((root_dir/'src/ReplicatedStorage/Shared').glob('*.lua')):
 item(shared,'ModuleScript',file.stem,file.read_text())
server,_=item(root,'ServerScriptService','ServerScriptService')
item(server,'Script','Game',(root_dir/'src/ServerScriptService/Game.server.lua').read_text())
player,_=item(root,'StarterPlayer','StarterPlayer')
scripts,_=item(player,'StarterPlayerScripts','StarterPlayerScripts')
item(scripts,'LocalScript','UI',(root_dir/'src/StarterPlayer/StarterPlayerScripts/UI.client.lua').read_text())
views,_=item(scripts,'Folder','Views')
for file in sorted((root_dir/'src/StarterPlayer/StarterPlayerScripts/Views').glob('*.lua')):
 item(views,'ModuleScript',file.stem,file.read_text())
xml=etree.tostring(root,encoding='utf-8',xml_declaration=True,pretty_print=True)
(root_dir/'CoolRPG_Prototype.rbxlx').write_bytes(xml)
assert etree.fromstring(xml).find('.//Item[@class="Script"]') is not None
expected=len(list((root_dir/'src/StarterPlayer/StarterPlayerScripts/Views').glob('*.lua')))+7
assert len(root.findall('.//ProtectedString'))==expected, (len(root.findall('.//ProtectedString')),expected)
print('Wrote .rbxlx:',len(xml),'bytes; script sources:',len(root.findall('.//ProtectedString')))
