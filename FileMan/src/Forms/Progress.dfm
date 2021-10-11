object FmProgress: TFmProgress
  Left = 193
  Top = 177
  BorderStyle = bsToolWindow
  ClientHeight = 138
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
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    574
    138)
  PixelsPerInch = 96
  TextHeight = 13
  object FileInd: TGauge
    Left = 5
    Top = 58
    Width = 564
    Height = 19
    Anchors = [akLeft, akRight, akBottom]
    ForeColor = clNavy
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Progress = 0
  end
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 26
    Height = 13
    Alignment = taRightJustify
    Caption = 'From:'
  end
  object Src: TLabel
    Left = 58
    Top = 24
    Width = 3
    Height = 13
  end
  object Label3: TLabel
    Left = 32
    Top = 40
    Width = 16
    Height = 13
    Alignment = taRightJustify
    Caption = 'To:'
  end
  object Target: TLabel
    Left = 58
    Top = 40
    Width = 3
    Height = 13
  end
  object Operation: TLabel
    Left = 203
    Top = 8
    Width = 56
    Height = 13
    Alignment = taCenter
    Caption = 'Operation'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object TotalInd: TGauge
    Left = 5
    Top = 83
    Width = 564
    Height = 19
    Anchors = [akLeft, akRight, akBottom]
    ForeColor = clNavy
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Progress = 0
  end
  object BtnCancel: TButton
    Left = 236
    Top = 108
    Width = 94
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    Default = True
    TabOrder = 0
    OnClick = BtnCancelClick
  end
end
