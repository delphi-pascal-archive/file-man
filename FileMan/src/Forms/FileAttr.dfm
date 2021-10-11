object FmAttr: TFmAttr
  Left = 237
  Top = 106
  BorderStyle = bsToolWindow
  ClientHeight = 161
  ClientWidth = 241
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    241
    161)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 5
    Top = 5
    Width = 231
    Height = 121
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Change attributes'
    TabOrder = 0
    object ChArch: TCheckBox
      Left = 10
      Top = 18
      Width = 150
      Height = 17
      Caption = 'Archieve'
      TabOrder = 0
    end
    object ChSys: TCheckBox
      Left = 10
      Top = 43
      Width = 150
      Height = 17
      Caption = 'System'
      TabOrder = 1
    end
    object ChHid: TCheckBox
      Left = 10
      Top = 68
      Width = 150
      Height = 17
      Caption = 'Hidden'
      TabOrder = 2
    end
    object ChRead: TCheckBox
      Left = 10
      Top = 94
      Width = 150
      Height = 17
      Caption = 'Read only'
      TabOrder = 3
    end
  end
  object BtnCancel: TButton
    Left = 79
    Top = 131
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtnOK: TButton
    Left = 162
    Top = 131
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
end
