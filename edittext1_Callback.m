%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

function edittext1_Callback(hObject, eventdata, handles)
global DisplayStepSize;
  user_entry = str2double(get(hObject,'string'));
  if isnan(user_entry)
    errordlg('You must enter a numeric value','Bad Input','modal')
    uicontrol(hObject)
    return
  end
  disp(user_entry);
  if user_entry<1
      user_entry=1;
  end
  DisplayStepSize=user_entry;
end

