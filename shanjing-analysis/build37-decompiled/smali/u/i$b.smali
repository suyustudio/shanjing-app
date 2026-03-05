.class public final Lu/i$b;
.super Landroid/speech/tts/UtteranceProgressListener;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lu/i;-><init>()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = null
.end annotation


# instance fields
.field final synthetic a:Lu/i;


# direct methods
.method constructor <init>(Lu/i;)V
    .locals 0

    iput-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-direct {p0}, Landroid/speech/tts/UtteranceProgressListener;-><init>()V

    return-void
.end method

.method private final a(Ljava/lang/String;II)V
    .locals 4

    if-eqz p1, :cond_0

    const/4 v0, 0x0

    const/4 v1, 0x2

    const/4 v2, 0x0

    const-string v3, "STF_"

    invoke-static {p1, v3, v0, v1, v2}, Lg1/d;->o(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->p(Lu/i;)Ljava/util/HashMap;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    const-string v1, "text"

    invoke-interface {v0, v1, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-static {p2}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v1

    const-string v2, "start"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-static {p3}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v1

    const-string v2, "end"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {p1, p2, p3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p1

    const-string p2, "this as java.lang.String\u2026ing(startIndex, endIndex)"

    invoke-static {p1, p2}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    const-string p2, "word"

    invoke-interface {v0, p2, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    const-string p2, "speak.onProgress"

    invoke-static {p1, p2, v0}, Lu/i;->q(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    :cond_0
    return-void
.end method


# virtual methods
.method public onDone(Ljava/lang/String;)V
    .locals 6

    const-string v0, "utteranceId"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "SIL_"

    const/4 v1, 0x0

    const/4 v2, 0x2

    const/4 v3, 0x0

    invoke-static {p1, v0, v1, v2, v3}, Lg1/d;->o(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    return-void

    :cond_0
    const-string v0, "STF_"

    invoke-static {p1, v0, v1, v2, v3}, Lg1/d;->o(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v0

    const/4 v2, 0x1

    const-string v4, "Utterance ID has completed: "

    if-eqz v0, :cond_2

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0, v1}, Lu/i;->k(Lu/i;Z)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->o(Lu/i;)Ljava/lang/String;

    move-result-object v0

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v0, v4}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->m(Lu/i;)Z

    move-result v0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-virtual {v0, v2}, Lu/i;->b0(I)V

    :cond_1
    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    sget-object v2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v4, "synth.onComplete"

    goto :goto_0

    :cond_2
    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->o(Lu/i;)Ljava/lang/String;

    move-result-object v0

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v0, v4}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->l(Lu/i;)Z

    move-result v0

    if-eqz v0, :cond_3

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->n(Lu/i;)I

    move-result v0

    if-nez v0, :cond_3

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-virtual {v0, v2}, Lu/i;->Y(I)V

    :cond_3
    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    sget-object v2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v4, "speak.onComplete"

    :goto_0
    invoke-static {v0, v4, v2}, Lu/i;->q(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0, v1}, Lu/i;->s(Lu/i;I)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0, v3}, Lu/i;->t(Lu/i;Ljava/lang/String;)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->p(Lu/i;)Ljava/util/HashMap;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/util/HashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method

.method public onError(Ljava/lang/String;)V
    .locals 4

    const-string v0, "utteranceId"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "STF_"

    const/4 v1, 0x0

    const/4 v2, 0x2

    const/4 v3, 0x0

    invoke-static {p1, v0, v1, v2, v3}, Lg1/d;->o(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_1

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    const/4 v0, 0x1

    invoke-static {p1, v0}, Lu/i;->k(Lu/i;Z)V

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1}, Lu/i;->m(Lu/i;)Z

    move-result p1

    if-eqz p1, :cond_0

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1, v1}, Lu/i;->w(Lu/i;Z)V

    :cond_0
    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    const-string v0, "synth.onError"

    const-string v1, "Error from TextToSpeech (synth)"

    goto :goto_0

    :cond_1
    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1}, Lu/i;->l(Lu/i;)Z

    move-result p1

    if-eqz p1, :cond_2

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1, v1}, Lu/i;->v(Lu/i;Z)V

    :cond_2
    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    const-string v0, "speak.onError"

    const-string v1, "Error from TextToSpeech (speak)"

    :goto_0
    invoke-static {p1, v0, v1}, Lu/i;->q(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method public onError(Ljava/lang/String;I)V
    .locals 4

    const-string v0, "utteranceId"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "STF_"

    const/4 v1, 0x0

    const/4 v2, 0x2

    const/4 v3, 0x0

    invoke-static {p1, v0, v1, v2, v3}, Lg1/d;->o(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_1

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    const/4 v0, 0x1

    invoke-static {p1, v0}, Lu/i;->k(Lu/i;Z)V

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1}, Lu/i;->m(Lu/i;)Z

    move-result p1

    if-eqz p1, :cond_0

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1, v1}, Lu/i;->w(Lu/i;Z)V

    :cond_0
    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Error from TextToSpeech (synth) - "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    const-string v0, "synth.onError"

    goto :goto_0

    :cond_1
    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1}, Lu/i;->l(Lu/i;)Z

    move-result p1

    if-eqz p1, :cond_2

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1, v1}, Lu/i;->v(Lu/i;Z)V

    :cond_2
    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Error from TextToSpeech (speak) - "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    const-string v0, "speak.onError"

    :goto_0
    invoke-static {p1, v0, p2}, Lu/i;->q(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method public onRangeStart(Ljava/lang/String;III)V
    .locals 4

    const-string v0, "utteranceId"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "STF_"

    const/4 v1, 0x0

    const/4 v2, 0x2

    const/4 v3, 0x0

    invoke-static {p1, v0, v1, v2, v3}, Lg1/d;->o(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0, p2}, Lu/i;->s(Lu/i;I)V

    invoke-super {p0, p1, p2, p3, p4}, Landroid/speech/tts/UtteranceProgressListener;->onRangeStart(Ljava/lang/String;III)V

    invoke-direct {p0, p1, p2, p3}, Lu/i$b;->a(Ljava/lang/String;II)V

    :cond_0
    return-void
.end method

.method public onStart(Ljava/lang/String;)V
    .locals 4

    const-string v0, "utteranceId"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "STF_"

    const/4 v1, 0x0

    const/4 v2, 0x2

    const/4 v3, 0x0

    invoke-static {p1, v0, v1, v2, v3}, Lg1/d;->o(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    sget-object v2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v3, "synth.onStart"

    :goto_0
    invoke-static {v0, v3, v2}, Lu/i;->q(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    goto :goto_1

    :cond_0
    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->r(Lu/i;)Z

    move-result v0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    sget-object v2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v3, "speak.onContinue"

    invoke-static {v0, v3, v2}, Lu/i;->q(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0, v1}, Lu/i;->u(Lu/i;Z)V

    goto :goto_1

    :cond_1
    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->o(Lu/i;)Ljava/lang/String;

    move-result-object v0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Utterance ID has started: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    sget-object v2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v3, "speak.onStart"

    goto :goto_0

    :goto_1
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1a

    if-ge v0, v2, :cond_2

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->p(Lu/i;)Ljava/util/HashMap;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    check-cast v0, Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    invoke-direct {p0, p1, v1, v0}, Lu/i$b;->a(Ljava/lang/String;II)V

    :cond_2
    return-void
.end method

.method public onStop(Ljava/lang/String;Z)V
    .locals 3

    const-string v0, "utteranceId"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    iget-object v0, p0, Lu/i$b;->a:Lu/i;

    invoke-static {v0}, Lu/i;->o(Lu/i;)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Utterance ID has been stopped: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, ". Interrupted: "

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1}, Lu/i;->l(Lu/i;)Z

    move-result p1

    if-eqz p1, :cond_0

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    const/4 p2, 0x0

    invoke-static {p1, p2}, Lu/i;->v(Lu/i;Z)V

    :cond_0
    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    invoke-static {p1}, Lu/i;->r(Lu/i;)Z

    move-result p1

    if-eqz p1, :cond_1

    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    sget-object p2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v0, "speak.onPause"

    goto :goto_0

    :cond_1
    iget-object p1, p0, Lu/i$b;->a:Lu/i;

    sget-object p2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v0, "speak.onCancel"

    :goto_0
    invoke-static {p1, v0, p2}, Lu/i;->q(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method
