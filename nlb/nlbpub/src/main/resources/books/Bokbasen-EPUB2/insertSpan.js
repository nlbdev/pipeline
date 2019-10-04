// Small Javascript that will insert a span-element into every header 
// and paragraph element to trick the iPad/iBooks into centering text.
// See http://infogridpacific.typepad.com/using_epub/2010/10/dirty-little-hacks-in-epub.html
function setSpanIGP(){
  var clsElementList=document.getElementsByTagName('p');
  setSpaninPara(clsElementList);
}

function setSpaninPara(pClassList){
  for(i=0;i<=pClassList.length;i++){
    if(pClassList[i]){
      var para_html=pClassList[i].innerHTML;
      para_html='<span>'+para_html+'</span>';
      pClassList[i].innerHTML=para_html;
    }
  }
}

function init(){setSpanIGP();}

window.onload=init;

