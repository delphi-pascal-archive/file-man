object FmDrive: TFmDrive
  Left = 225
  Top = 198
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Select new drive'
  ClientHeight = 23
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 6
    Width = 59
    Height = 13
    Caption = 'Select drive:'
  end
  object DrvCombo: TComboBox
    Left = 114
    Top = 2
    Width = 189
    Height = 19
    Style = csOwnerDrawFixed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ItemHeight = 13
    ItemIndex = 0
    ParentFont = False
    TabOrder = 0
    Text = '1'
    OnDrawItem = DrvComboDrawItem
    OnSelect = DrvComboSelect
    Items.Strings = (
      '1'
      '2'
      '3'
      '4')
  end
end
