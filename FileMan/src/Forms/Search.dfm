object FmSearch: TFmSearch
  Left = 194
  Top = 144
  Width = 549
  Height = 247
  BorderStyle = bsSizeToolWin
  BorderWidth = 3
  Color = clBtnFace
  Constraints.MinHeight = 219
  Constraints.MinWidth = 265
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Pan1: TPanel
    Left = 0
    Top = 0
    Width = 535
    Height = 195
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 1
    DesignSize = (
      535
      195)
    object Label1: TLabel
      Left = 8
      Top = 4
      Width = 79
      Height = 13
      Caption = 'Search for file(s):'
    end
    object Label2: TLabel
      Left = 8
      Top = 48
      Width = 48
      Height = 13
      Caption = 'Search in:'
    end
    object Label3: TLabel
      Left = 8
      Top = 100
      Width = 85
      Height = 13
      Caption = 'Files: 0; Folders: 0'
    end
    object MaskEd: TEdit
      Left = 6
      Top = 19
      Width = 438
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object BtnAct: TButton
      Left = 454
      Top = 19
      Width = 75
      Height = 20
      Anchors = [akTop, akRight]
      Caption = 'Start'
      Default = True
      TabOrder = 3
      OnClick = BtnActClick
    end
    object BtnCancel: TButton
      Left = 454
      Top = 43
      Width = 75
      Height = 20
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      TabOrder = 4
      OnClick = BtnCancelClick
    end
    object PathEd: TEdit
      Left = 6
      Top = 63
      Width = 438
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object FindList: TListBox
      Left = 2
      Top = 117
      Width = 531
      Height = 76
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelInner = bvNone
      BevelOuter = bvSpace
      BorderStyle = bsNone
      ItemHeight = 13
      Items.Strings = (
        '<-no files found->')
      TabOrder = 2
      OnDblClick = FindListDblClick
    end
  end
  object StBar: TStatusBar
    Left = 0
    Top = 195
    Width = 535
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
end
