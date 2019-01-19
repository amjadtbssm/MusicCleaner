object RenameForm: TRenameForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Rename Selected File'
  ClientHeight = 215
  ClientWidth = 488
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LblStatus: TLabel
    Left = 22
    Top = 20
    Width = 210
    Height = 19
    AutoSize = False
    Caption = 'Rename Selected File:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object EdtRename: TEdit
    Left = 22
    Top = 52
    Width = 433
    Height = 31
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnKeyDown = EdtRenameKeyDown
  end
  object BtnRename: TButton
    Left = 88
    Top = 120
    Width = 121
    Height = 49
    Caption = 'Rename File'
    TabOrder = 1
    OnClick = BtnRenameClick
  end
  object BtnCancel: TButton
    Left = 264
    Top = 120
    Width = 121
    Height = 49
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = BtnCancelClick
  end
  object EdtExt: TEdit
    Left = 22
    Top = 126
    Width = 27
    Height = 31
    TabStop = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Visible = False
    OnKeyDown = EdtRenameKeyDown
  end
end
