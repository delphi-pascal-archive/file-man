object FmMain: TFmMain
  Left = 219
  Top = 124
  Width = 819
  Height = 614
  Caption = 'FileMan'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    000000000F0000F00000000000000000000000000F0000F00000000000000000
    000000008F8008F80000000000000000000000007F7007F70000000000000000
    00000000FFF00FFF000000000000000000000000FFF00FFF0000000000000000
    00000000FFF00FFF000000000000000000000000FFF00FFF0000000000000000
    00000008FFF00FFF80000000000000000000087FFFFFFFFFF780000000000000
    000087FFFFFFFFFFFF780000000000000008FFFFFFFFFFFFFFFF800000000000
    008FFFFFFFFFFFFFFFFFF8000000000008FFFFF37FF00FF73FFFFF8000000000
    07FFF300FFF00FFF003FFF70000000008FFF3800FFF00FFF0083FFF700000000
    7FF38007FFF77FFF70083FF700000000FFF8008FFFFFFFFFF8007FFF00000008
    FF30008800000000880003FF80000008FF70000000000000000007FF80000008
    FF80000000000000000008FF80000008FF80000000000000000008FF80000008
    FF80000000000000000008FF80000008FF80000000000000000008FF80000000
    3F80000000000000000008F3000000007F70000000000000000007F700000000
    0F30000000000000000003F80000000007F800000000000000008F7000000000
    00FF0000000000000008FF0000000000000F3000000000000083F00000000000
    0000F78000000000087F00000000000000000878000000008780000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Panel2: TPanel
    Left = 0
    Top = 521
    Width = 811
    Height = 65
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      811
      65)
    object CmdPrompt: TEdit
      Left = 5
      Top = 5
      Width = 964
      Height = 21
      TabStop = False
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 0
    end
    object ToolBar1: TToolBar
      Left = 1
      Top = 40
      Width = 809
      Height = 24
      Align = alBottom
      ButtonWidth = 56
      Caption = 'ToolBar1'
      Flat = True
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      ShowCaptions = True
      TabOrder = 1
      Wrapable = False
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Caption = 'F5-Copy'
        ImageIndex = 0
      end
      object ToolButton2: TToolButton
        Left = 56
        Top = 0
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object ToolButton3: TToolButton
        Left = 64
        Top = 0
        Caption = 'F5-Copy'
        ImageIndex = 1
      end
      object ToolButton4: TToolButton
        Left = 120
        Top = 0
        Width = 8
        Caption = 'ToolButton4'
        ImageIndex = 2
        Style = tbsSeparator
      end
      object ToolButton5: TToolButton
        Left = 128
        Top = 0
        Caption = 'F5-Copy'
        ImageIndex = 2
      end
      object ToolButton6: TToolButton
        Left = 184
        Top = 0
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton7: TToolButton
        Left = 192
        Top = 0
        Caption = 'F5-Copy'
        ImageIndex = 3
      end
      object ToolButton8: TToolButton
        Left = 248
        Top = 0
        Width = 8
        Caption = 'ToolButton8'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object ToolButton9: TToolButton
        Left = 256
        Top = 0
        Caption = 'F5-Copy'
        ImageIndex = 4
      end
      object ToolButton10: TToolButton
        Left = 312
        Top = 0
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object ToolButton11: TToolButton
        Left = 320
        Top = 0
        Caption = 'F5-Copy'
        ImageIndex = 5
      end
      object ToolButton12: TToolButton
        Left = 376
        Top = 0
        Width = 8
        Caption = 'ToolButton12'
        ImageIndex = 6
        Style = tbsSeparator
      end
      object ToolButton13: TToolButton
        Left = 384
        Top = 0
        Caption = 'F5-Copy'
        ImageIndex = 6
      end
      object ToolButton14: TToolButton
        Left = 440
        Top = 0
        Width = 8
        Caption = 'ToolButton14'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object ToolButton15: TToolButton
        Left = 448
        Top = 0
        Caption = 'F5-Copy'
        ImageIndex = 7
      end
      object ToolButton16: TToolButton
        Left = 504
        Top = 0
        Width = 8
        Caption = 'ToolButton16'
        ImageIndex = 8
        Style = tbsSeparator
      end
      object ToolButton17: TToolButton
        Left = 512
        Top = 0
        Caption = 'F5'
        ImageIndex = 8
      end
      object ToolButton18: TToolButton
        Left = 568
        Top = 0
        Width = 8
        Caption = 'ToolButton18'
        ImageIndex = 9
        Style = tbsSeparator
      end
      object ToolButton19: TToolButton
        Left = 576
        Top = 0
        Caption = 'F5'
        ImageIndex = 9
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 811
    Height = 521
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 428
      Top = 0
      Width = 4
      Height = 521
      OnMoved = Splitter1Moved
    end
    object LPanel: TPanel
      Left = 0
      Top = 0
      Width = 428
      Height = 521
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
    end
    object RPanel: TPanel
      Left = 432
      Top = 0
      Width = 379
      Height = 521
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    Left = 487
    Top = 40
  end
end
