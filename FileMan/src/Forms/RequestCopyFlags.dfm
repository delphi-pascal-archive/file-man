object FmGetFlags: TFmGetFlags
  Left = 196
  Top = 246
  BorderStyle = bsToolWindow
  ClientHeight = 155
  ClientWidth = 574
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    574
    155)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 13
    Top = 6
    Width = 43
    Height = 13
    Alignment = taRightJustify
    Caption = 'Replace:'
  end
  object lFile01: TLabel
    Left = 60
    Top = 6
    Width = 3
    Height = 13
  end
  object lFile01info: TLabel
    Left = 35
    Top = 23
    Width = 3
    Height = 13
  end
  object Label2: TLabel
    Left = 30
    Top = 48
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Caption = 'With:'
  end
  object lFile02: TLabel
    Left = 60
    Top = 48
    Width = 3
    Height = 13
  end
  object lFile02info: TLabel
    Left = 35
    Top = 65
    Width = 3
    Height = 13
  end
  object Bevel1: TBevel
    Left = 4
    Top = 41
    Width = 429
    Height = 7
    Shape = bsTopLine
  end
  object Panel1: TPanel
    Left = 4
    Top = 88
    Width = 429
    Height = 63
    Anchors = [akLeft, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Button1: TButton
      Left = 5
      Top = 5
      Width = 100
      Height = 22
      Caption = 'Replace'
      Default = True
      TabOrder = 0
    end
    object Button2: TButton
      Left = 111
      Top = 5
      Width = 100
      Height = 22
      Caption = 'Replace all'
      TabOrder = 1
    end
    object Button3: TButton
      Left = 217
      Top = 5
      Width = 100
      Height = 22
      Caption = 'Skip'
      TabOrder = 2
    end
    object Button4: TButton
      Left = 324
      Top = 5
      Width = 100
      Height = 22
      Caption = 'Skip all'
      TabOrder = 3
    end
    object Button5: TButton
      Left = 5
      Top = 36
      Width = 100
      Height = 22
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 4
    end
  end
end
