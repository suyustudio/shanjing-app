.class public final synthetic Lu/c;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroid/speech/tts/TextToSpeech$OnInitListener;


# instance fields
.field public final synthetic a:Lu/i;


# direct methods
.method public synthetic constructor <init>(Lu/i;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lu/c;->a:Lu/i;

    return-void
.end method


# virtual methods
.method public final onInit(I)V
    .locals 1

    iget-object v0, p0, Lu/c;->a:Lu/i;

    invoke-static {v0, p1}, Lu/i;->e(Lu/i;I)V

    return-void
.end method
