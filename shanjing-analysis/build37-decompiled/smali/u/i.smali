.class public final Lu/i;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/k$c;
.implements Lb0/a;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lu/i$a;
    }
.end annotation


# static fields
.field public static final A:Lu/i$a;


# instance fields
.field private a:Landroid/os/Handler;

.field private b:Lj0/k;

.field private c:Lj0/k$d;

.field private d:Lj0/k$d;

.field private e:Z

.field private f:Z

.field private g:Z

.field private h:Z

.field private i:Landroid/content/Context;

.field private j:Landroid/speech/tts/TextToSpeech;

.field private final k:Ljava/lang/String;

.field private final l:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Ljava/lang/Runnable;",
            ">;"
        }
    .end annotation
.end field

.field private final m:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private n:Landroid/os/Bundle;

.field private o:I

.field private p:I

.field private q:Ljava/lang/String;

.field private r:Ljava/lang/String;

.field private s:Z

.field private t:I

.field private u:Ljava/lang/Integer;

.field private v:Lj0/k$d;

.field private w:Landroid/os/ParcelFileDescriptor;

.field private final x:Landroid/speech/tts/UtteranceProgressListener;

.field private final y:Landroid/speech/tts/TextToSpeech$OnInitListener;

.field private final z:Landroid/speech/tts/TextToSpeech$OnInitListener;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lu/i$a;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lu/i$a;-><init>(Lkotlin/jvm/internal/e;)V

    sput-object v0, Lu/i;->A:Lu/i$a;

    return-void
.end method

.method public constructor <init>()V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const-string v0, "TTS"

    iput-object v0, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lu/i;->l:Ljava/util/ArrayList;

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lu/i;->m:Ljava/util/HashMap;

    new-instance v0, Lu/i$b;

    invoke-direct {v0, p0}, Lu/i$b;-><init>(Lu/i;)V

    iput-object v0, p0, Lu/i;->x:Landroid/speech/tts/UtteranceProgressListener;

    new-instance v0, Lu/b;

    invoke-direct {v0, p0}, Lu/b;-><init>(Lu/i;)V

    iput-object v0, p0, Lu/i;->y:Landroid/speech/tts/TextToSpeech$OnInitListener;

    new-instance v0, Lu/c;

    invoke-direct {v0, p0}, Lu/c;-><init>(Lu/i;)V

    iput-object v0, p0, Lu/i;->z:Landroid/speech/tts/TextToSpeech$OnInitListener;

    return-void
.end method

.method private static final A(Lu/i;I)V
    .locals 2

    const-string v0, "this$0"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    monitor-enter p0

    :try_start_0
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    iput-object v0, p0, Lu/i;->u:Ljava/lang/Integer;

    iget-object v0, p0, Lu/i;->l:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Runnable;

    invoke-interface {v1}, Ljava/lang/Runnable;->run()V

    goto :goto_0

    :cond_0
    iget-object v0, p0, Lu/i;->l:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    sget-object v0, Lq0/q;->a:Lq0/q;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    monitor-exit p0

    if-nez p1, :cond_1

    iget-object p1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget-object v0, p0, Lu/i;->x:Landroid/speech/tts/UtteranceProgressListener;

    invoke-virtual {p1, v0}, Landroid/speech/tts/TextToSpeech;->setOnUtteranceProgressListener(Landroid/speech/tts/UtteranceProgressListener;)I

    :try_start_1
    iget-object p1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {p1}, Landroid/speech/tts/TextToSpeech;->getDefaultVoice()Landroid/speech/tts/Voice;

    move-result-object p1

    invoke-virtual {p1}, Landroid/speech/tts/Voice;->getLocale()Ljava/util/Locale;

    move-result-object p1

    const-string v0, "getLocale(...)"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0, p1}, Lu/i;->L(Ljava/util/Locale;)Z

    move-result v0

    if-eqz v0, :cond_2

    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0, p1}, Landroid/speech/tts/TextToSpeech;->setLanguage(Ljava/util/Locale;)I
    :try_end_1
    .catch Ljava/lang/NullPointerException; {:try_start_1 .. :try_end_1} :catch_1
    .catch Ljava/lang/IllegalArgumentException; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_3

    :catch_0
    move-exception p1

    iget-object p0, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    goto :goto_1

    :catch_1
    move-exception p1

    iget-object p0, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    :goto_1
    const-string v1, "getDefaultLocale: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_2

    :cond_1
    iget-object p0, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Failed to initialize TextToSpeech with status: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    :goto_2
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_2
    :goto_3
    return-void

    :catchall_0
    move-exception p1

    monitor-exit p0

    throw p1
.end method

.method private final B(Lj0/k$d;)V
    .locals 1

    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0}, Landroid/speech/tts/TextToSpeech;->getDefaultEngine()Ljava/lang/String;

    move-result-object v0

    invoke-interface {p1, v0}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final C(Lj0/k$d;)V
    .locals 4

    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0}, Landroid/speech/tts/TextToSpeech;->getDefaultVoice()Landroid/speech/tts/Voice;

    move-result-object v0

    new-instance v1, Ljava/util/HashMap;

    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Landroid/speech/tts/Voice;->getName()Ljava/lang/String;

    move-result-object v2

    const-string v3, "getName(...)"

    invoke-static {v2, v3}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v3, "name"

    invoke-interface {v1, v3, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-virtual {v0}, Landroid/speech/tts/Voice;->getLocale()Ljava/util/Locale;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v0

    const-string v2, "toLanguageTag(...)"

    invoke-static {v0, v2}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v2, "locale"

    invoke-interface {v1, v2, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_0
    invoke-interface {p1, v1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final D(Lj0/k$d;)V
    .locals 5

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v1}, Landroid/speech/tts/TextToSpeech;->getEngines()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/speech/tts/TextToSpeech$EngineInfo;

    iget-object v2, v2, Landroid/speech/tts/TextToSpeech$EngineInfo;->name:Ljava/lang/String;

    invoke-virtual {v0, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v1

    iget-object v2, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "getEngines: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v2, v1}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    :cond_0
    invoke-interface {p1, v0}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final E(Lj0/k$d;)V
    .locals 9

    const-string v0, "getLanguages: "

    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x17

    if-lt v2, v3, :cond_0

    iget-object v2, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v2}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v2}, Landroid/speech/tts/TextToSpeech;->getAvailableLanguages()Ljava/util/Set;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_3

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Locale;

    invoke-virtual {v3}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_0

    :cond_0
    invoke-static {}, Ljava/util/Locale;->getAvailableLocales()[Ljava/util/Locale;

    move-result-object v2

    const-string v3, "getAvailableLocales(...)"

    invoke-static {v2, v3}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    array-length v3, v2

    const/4 v4, 0x0

    const/4 v5, 0x0

    :goto_1
    if-ge v5, v3, :cond_3

    aget-object v6, v2, v5

    invoke-virtual {v6}, Ljava/util/Locale;->getVariant()Ljava/lang/String;

    move-result-object v7

    const-string v8, "getVariant(...)"

    invoke-static {v7, v8}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-interface {v7}, Ljava/lang/CharSequence;->length()I

    move-result v7

    if-nez v7, :cond_1

    const/4 v7, 0x1

    goto :goto_2

    :cond_1
    const/4 v7, 0x0

    :goto_2
    if-eqz v7, :cond_2

    invoke-direct {p0, v6}, Lu/i;->L(Ljava/util/Locale;)Z

    move-result v7

    if-eqz v7, :cond_2

    invoke-virtual {v6}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v6}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/util/MissingResourceException; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/NullPointerException; {:try_start_0 .. :try_end_0} :catch_0

    :cond_2
    add-int/lit8 v5, v5, 0x1

    goto :goto_1

    :catch_0
    move-exception v2

    iget-object v3, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    goto :goto_3

    :catch_1
    move-exception v2

    iget-object v3, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    :goto_3
    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v3, v0}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    :cond_3
    invoke-interface {p1, v1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final F()I
    .locals 1

    invoke-static {}, Landroid/speech/tts/TextToSpeech;->getMaxSpeechInputLength()I

    move-result v0

    return v0
.end method

.method private final G(Lj0/k$d;)V
    .locals 3

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    const-string v1, "min"

    const-string v2, "0"

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v1, "normal"

    const-string v2, "0.5"

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v1, "max"

    const-string v2, "1.5"

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v1, "platform"

    const-string v2, "android"

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-interface {p1, v0}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final H(Lj0/k$d;)V
    .locals 7

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    :try_start_0
    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v1}, Landroid/speech/tts/TextToSpeech;->getVoices()Ljava/util/Set;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/speech/tts/Voice;

    new-instance v3, Ljava/util/HashMap;

    invoke-direct {v3}, Ljava/util/HashMap;-><init>()V

    const-string v4, "name"

    invoke-virtual {v2}, Landroid/speech/tts/Voice;->getName()Ljava/lang/String;

    move-result-object v5

    const-string v6, "getName(...)"

    invoke-static {v5, v6}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-interface {v3, v4, v5}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v4, "locale"

    invoke-virtual {v2}, Landroid/speech/tts/Voice;->getLocale()Ljava/util/Locale;

    move-result-object v2

    invoke-virtual {v2}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v2

    const-string v5, "toLanguageTag(...)"

    invoke-static {v2, v5}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-interface {v3, v4, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    invoke-virtual {v0, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_0

    :cond_0
    invoke-interface {p1, v0}, Lj0/k$d;->a(Ljava/lang/Object;)V
    :try_end_0
    .catch Ljava/lang/NullPointerException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    :catch_0
    move-exception v0

    iget-object v1, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "getVoices: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    const/4 v0, 0x0

    invoke-interface {p1, v0}, Lj0/k$d;->a(Ljava/lang/Object;)V

    :goto_1
    return-void
.end method

.method private final I(Lj0/c;Landroid/content/Context;)V
    .locals 2

    iput-object p2, p0, Lu/i;->i:Landroid/content/Context;

    new-instance v0, Lj0/k;

    const-string v1, "flutter_tts"

    invoke-direct {v0, p1, v1}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;)V

    iput-object v0, p0, Lu/i;->b:Lj0/k;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0, p0}, Lj0/k;->e(Lj0/k$c;)V

    new-instance p1, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-direct {p1, v0}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object p1, p0, Lu/i;->a:Landroid/os/Handler;

    new-instance p1, Landroid/os/Bundle;

    invoke-direct {p1}, Landroid/os/Bundle;-><init>()V

    iput-object p1, p0, Lu/i;->n:Landroid/os/Bundle;

    new-instance p1, Landroid/speech/tts/TextToSpeech;

    iget-object v0, p0, Lu/i;->z:Landroid/speech/tts/TextToSpeech$OnInitListener;

    invoke-direct {p1, p2, v0}, Landroid/speech/tts/TextToSpeech;-><init>(Landroid/content/Context;Landroid/speech/tts/TextToSpeech$OnInitListener;)V

    iput-object p1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    return-void
.end method

.method private final J(Ljava/lang/String;Ljava/lang/Object;)V
    .locals 2

    iget-object v0, p0, Lu/i;->a:Landroid/os/Handler;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    new-instance v1, Lu/f;

    invoke-direct {v1, p0, p1, p2}, Lu/f;-><init>(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method private static final K(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 1

    const-string v0, "this$0"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "$method"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "$arguments"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    iget-object p0, p0, Lu/i;->b:Lj0/k;

    if-eqz p0, :cond_0

    invoke-static {p0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {p0, p1, p2}, Lj0/k;->c(Ljava/lang/String;Ljava/lang/Object;)V

    :cond_0
    return-void
.end method

.method private final L(Ljava/util/Locale;)Z
    .locals 1

    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0, p1}, Landroid/speech/tts/TextToSpeech;->isLanguageAvailable(Ljava/util/Locale;)I

    move-result p1

    if-ltz p1, :cond_0

    const/4 p1, 0x1

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    :goto_0
    return p1
.end method

.method private final M(Ljava/lang/String;)Z
    .locals 4

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-static {p1}, Ljava/util/Locale;->forLanguageTag(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object p1

    const-string v0, "forLanguageTag(...)"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0, p1}, Lu/i;->L(Ljava/util/Locale;)Z

    move-result v0

    if-eqz v0, :cond_2

    const/4 v0, 0x0

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v1}, Landroid/speech/tts/TextToSpeech;->getVoices()Ljava/util/Set;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/speech/tts/Voice;

    invoke-virtual {v2}, Landroid/speech/tts/Voice;->getLocale()Ljava/util/Locale;

    move-result-object v3

    invoke-static {v3, p1}, Lkotlin/jvm/internal/i;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-virtual {v2}, Landroid/speech/tts/Voice;->isNetworkConnectionRequired()Z

    move-result v3

    if-nez v3, :cond_0

    move-object v0, v2

    :cond_1
    if-eqz v0, :cond_2

    invoke-virtual {v0}, Landroid/speech/tts/Voice;->getFeatures()Ljava/util/Set;

    move-result-object p1

    const-string v0, "getFeatures(...)"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "notInstalled"

    invoke-interface {p1, v0}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z

    move-result p1

    xor-int/lit8 p1, p1, 0x1

    return p1

    :cond_2
    const/4 p1, 0x0

    return p1
.end method

.method private final N(Landroid/speech/tts/TextToSpeech;)Z
    .locals 9

    const/4 v0, 0x0

    if-nez p1, :cond_0

    return v0

    :cond_0
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Class;->getDeclaredFields()[Ljava/lang/reflect/Field;

    move-result-object v1

    const-string v2, "getDeclaredFields(...)"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    array-length v2, v1

    const/4 v3, 0x1

    const/4 v4, 0x0

    const/4 v5, 0x1

    :goto_0
    if-ge v4, v2, :cond_2

    aget-object v6, v1, v4

    invoke-virtual {v6, v3}, Ljava/lang/reflect/AccessibleObject;->setAccessible(Z)V

    aget-object v6, v1, v4

    invoke-virtual {v6}, Ljava/lang/reflect/Field;->getName()Ljava/lang/String;

    move-result-object v6

    const-string v7, "mServiceConnection"

    invoke-static {v7, v6}, Lkotlin/jvm/internal/i;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_1

    aget-object v6, v1, v4

    invoke-virtual {v6}, Ljava/lang/reflect/Field;->getType()Ljava/lang/Class;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v6

    const-string v7, "android.speech.tts.TextToSpeech$Connection"

    invoke-static {v7, v6}, Lkotlin/jvm/internal/i;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_1

    :try_start_0
    aget-object v6, v1, v4

    invoke-virtual {v6, p1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v6
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_5
    .catch Ljava/lang/IllegalAccessException; {:try_start_0 .. :try_end_0} :catch_4
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_3

    if-nez v6, :cond_1

    :try_start_1
    iget-object v5, p0, Lu/i;->k:Ljava/lang/String;

    const-string v6, "*******TTS -> mServiceConnection == null*******"

    invoke-static {v5, v6}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/IllegalArgumentException; {:try_start_1 .. :try_end_1} :catch_2
    .catch Ljava/lang/IllegalAccessException; {:try_start_1 .. :try_end_1} :catch_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    const/4 v5, 0x0

    goto :goto_4

    :catch_0
    move-exception v5

    goto :goto_1

    :catch_1
    move-exception v5

    goto :goto_1

    :catch_2
    move-exception v5

    :goto_1
    const/4 v6, 0x0

    goto :goto_3

    :catch_3
    move-exception v6

    goto :goto_2

    :catch_4
    move-exception v6

    goto :goto_2

    :catch_5
    move-exception v6

    :goto_2
    move-object v8, v6

    move v6, v5

    move-object v5, v8

    :goto_3
    invoke-virtual {v5}, Ljava/lang/Throwable;->printStackTrace()V

    move v5, v6

    :cond_1
    :goto_4
    add-int/lit8 v4, v4, 0x1

    goto :goto_0

    :cond_2
    return v5
.end method

.method private static final O(Lu/i;I)V
    .locals 5

    const-string v0, "this$0"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    monitor-enter p0

    :try_start_0
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    iput-object v0, p0, Lu/i;->u:Ljava/lang/Integer;

    iget-object v0, p0, Lu/i;->l:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Runnable;

    invoke-interface {v1}, Ljava/lang/Runnable;->run()V

    goto :goto_0

    :cond_0
    iget-object v0, p0, Lu/i;->l:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    sget-object v0, Lq0/q;->a:Lq0/q;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    monitor-exit p0

    const/4 v0, 0x0

    if-nez p1, :cond_2

    iget-object p1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget-object v1, p0, Lu/i;->x:Landroid/speech/tts/UtteranceProgressListener;

    invoke-virtual {p1, v1}, Landroid/speech/tts/TextToSpeech;->setOnUtteranceProgressListener(Landroid/speech/tts/UtteranceProgressListener;)I

    :try_start_1
    iget-object p1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {p1}, Landroid/speech/tts/TextToSpeech;->getDefaultVoice()Landroid/speech/tts/Voice;

    move-result-object p1

    invoke-virtual {p1}, Landroid/speech/tts/Voice;->getLocale()Ljava/util/Locale;

    move-result-object p1

    const-string v1, "getLocale(...)"

    invoke-static {p1, v1}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0, p1}, Lu/i;->L(Ljava/util/Locale;)Z

    move-result v1

    if-eqz v1, :cond_1

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v1, p1}, Landroid/speech/tts/TextToSpeech;->setLanguage(Ljava/util/Locale;)I
    :try_end_1
    .catch Ljava/lang/NullPointerException; {:try_start_1 .. :try_end_1} :catch_1
    .catch Ljava/lang/IllegalArgumentException; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_2

    :catch_0
    move-exception p1

    iget-object v1, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    goto :goto_1

    :catch_1
    move-exception p1

    iget-object v1, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    :goto_1
    const-string v3, "getDefaultLocale: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :cond_1
    :goto_2
    iget-object p1, p0, Lu/i;->v:Lj0/k$d;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-interface {p1, v1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    goto :goto_3

    :cond_2
    iget-object v1, p0, Lu/i;->v:Lj0/k$d;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    const-string v2, "TtsError"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Failed to initialize TextToSpeech with status: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-interface {v1, v2, p1, v0}, Lj0/k$d;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    :goto_3
    iput-object v0, p0, Lu/i;->v:Lj0/k$d;

    return-void

    :catchall_0
    move-exception p1

    monitor-exit p0

    throw p1
.end method

.method private static final P(Lu/i;Lj0/j;Lj0/k$d;)V
    .locals 1

    const-string v0, "this$0"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "$call"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "$result"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, p1, p2}, Lu/i;->h(Lj0/j;Lj0/k$d;)V

    return-void
.end method

.method private static final Q(Lu/i;Lj0/j;Lj0/k$d;)V
    .locals 1

    const-string v0, "this$0"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "$call"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "$result"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, p1, p2}, Lu/i;->h(Lj0/j;Lj0/k$d;)V

    return-void
.end method

.method private final R(Ljava/lang/String;Lj0/k$d;)V
    .locals 2

    const/4 v0, 0x0

    iput-object v0, p0, Lu/i;->u:Ljava/lang/Integer;

    iput-object p2, p0, Lu/i;->v:Lj0/k$d;

    new-instance p2, Landroid/speech/tts/TextToSpeech;

    iget-object v0, p0, Lu/i;->i:Landroid/content/Context;

    iget-object v1, p0, Lu/i;->y:Landroid/speech/tts/TextToSpeech$OnInitListener;

    invoke-direct {p2, v0, v1, p1}, Landroid/speech/tts/TextToSpeech;-><init>(Landroid/content/Context;Landroid/speech/tts/TextToSpeech$OnInitListener;Ljava/lang/String;)V

    iput-object p2, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    return-void
.end method

.method private final S(Ljava/lang/String;Lj0/k$d;)V
    .locals 1

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-static {p1}, Ljava/util/Locale;->forLanguageTag(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object p1

    const-string v0, "forLanguageTag(...)"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0, p1}, Lu/i;->L(Ljava/util/Locale;)Z

    move-result v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0, p1}, Landroid/speech/tts/TextToSpeech;->setLanguage(Ljava/util/Locale;)I

    const/4 p1, 0x1

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    :goto_0
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final T(FLj0/k$d;)V
    .locals 4

    const/4 v0, 0x1

    const/4 v1, 0x0

    const/high16 v2, 0x3f000000    # 0.5f

    cmpg-float v2, v2, p1

    if-gtz v2, :cond_0

    const/high16 v2, 0x40000000    # 2.0f

    cmpg-float v2, p1, v2

    if-gtz v2, :cond_0

    const/4 v2, 0x1

    goto :goto_0

    :cond_0
    const/4 v2, 0x0

    :goto_0
    if-eqz v2, :cond_1

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v1, p1}, Landroid/speech/tts/TextToSpeech;->setPitch(F)I

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    goto :goto_1

    :cond_1
    iget-object v0, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Invalid pitch "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string p1, " value - Range is from 0.5 to 2.0"

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    :goto_1
    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final U(F)V
    .locals 1

    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0, p1}, Landroid/speech/tts/TextToSpeech;->setSpeechRate(F)I

    return-void
.end method

.method private final V(Ljava/util/HashMap;Lj0/k$d;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/HashMap<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;",
            "Lj0/k$d;",
            ")V"
        }
    .end annotation

    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0}, Landroid/speech/tts/TextToSpeech;->getVoices()Ljava/util/Set;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :cond_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/speech/tts/Voice;

    invoke-virtual {v1}, Landroid/speech/tts/Voice;->getName()Ljava/lang/String;

    move-result-object v2

    const-string v3, "name"

    invoke-virtual {p1, v3}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    invoke-static {v2, v3}, Lkotlin/jvm/internal/i;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-virtual {v1}, Landroid/speech/tts/Voice;->getLocale()Ljava/util/Locale;

    move-result-object v2

    invoke-virtual {v2}, Ljava/util/Locale;->toLanguageTag()Ljava/lang/String;

    move-result-object v2

    const-string v3, "locale"

    invoke-virtual {p1, v3}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    invoke-static {v2, v3}, Lkotlin/jvm/internal/i;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    iget-object p1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {p1, v1}, Landroid/speech/tts/TextToSpeech;->setVoice(Landroid/speech/tts/Voice;)I

    const/4 p1, 0x1

    :goto_0
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void

    :cond_1
    iget-object v0, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Voice name not found: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    const/4 p1, 0x0

    goto :goto_0
.end method

.method private final W(FLj0/k$d;)V
    .locals 4

    const/4 v0, 0x1

    const/4 v1, 0x0

    const/4 v2, 0x0

    cmpg-float v2, v2, p1

    if-gtz v2, :cond_0

    const/high16 v2, 0x3f800000    # 1.0f

    cmpg-float v2, p1, v2

    if-gtz v2, :cond_0

    const/4 v2, 0x1

    goto :goto_0

    :cond_0
    const/4 v2, 0x0

    :goto_0
    if-eqz v2, :cond_1

    iget-object v1, p0, Lu/i;->n:Landroid/os/Bundle;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    const-string v2, "volume"

    invoke-virtual {v1, v2, p1}, Landroid/os/Bundle;->putFloat(Ljava/lang/String;F)V

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    goto :goto_1

    :cond_1
    iget-object v0, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Invalid volume "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    const-string p1, " value - Range is from 0.0 to 1.0"

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    :goto_1
    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final X(Ljava/lang/String;)Z
    .locals 8

    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "toString(...)"

    invoke-static {v0, v1}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    iget-object v1, p0, Lu/i;->m:Ljava/util/HashMap;

    invoke-interface {v1, v0, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-direct {p0, v1}, Lu/i;->N(Landroid/speech/tts/TextToSpeech;)Z

    move-result v1

    const/4 v2, 0x1

    const/4 v3, 0x0

    if-eqz v1, :cond_1

    iget v1, p0, Lu/i;->o:I

    if-lez v1, :cond_0

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget v4, p0, Lu/i;->o:I

    int-to-long v4, v4

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "SIL_"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v4, v5, v3, v6}, Landroid/speech/tts/TextToSpeech;->playSilentUtterance(JILjava/lang/String;)I

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget-object v4, p0, Lu/i;->n:Landroid/os/Bundle;

    invoke-virtual {v1, p1, v2, v4, v0}, Landroid/speech/tts/TextToSpeech;->speak(Ljava/lang/CharSequence;ILandroid/os/Bundle;Ljava/lang/String;)I

    move-result p1

    if-nez p1, :cond_2

    goto :goto_0

    :cond_0
    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget v4, p0, Lu/i;->t:I

    iget-object v5, p0, Lu/i;->n:Landroid/os/Bundle;

    invoke-virtual {v1, p1, v4, v5, v0}, Landroid/speech/tts/TextToSpeech;->speak(Ljava/lang/CharSequence;ILandroid/os/Bundle;Ljava/lang/String;)I

    move-result p1

    if-nez p1, :cond_2

    goto :goto_0

    :cond_1
    const/4 p1, 0x0

    iput-object p1, p0, Lu/i;->u:Ljava/lang/Integer;

    new-instance p1, Landroid/speech/tts/TextToSpeech;

    iget-object v0, p0, Lu/i;->i:Landroid/content/Context;

    iget-object v1, p0, Lu/i;->y:Landroid/speech/tts/TextToSpeech$OnInitListener;

    invoke-direct {p1, v0, v1}, Landroid/speech/tts/TextToSpeech;-><init>(Landroid/content/Context;Landroid/speech/tts/TextToSpeech$OnInitListener;)V

    iput-object p1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    :cond_2
    const/4 v2, 0x0

    :goto_0
    return v2
.end method

.method private static final Z(Lu/i;I)V
    .locals 1

    const-string v0, "this$0"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    iget-object v0, p0, Lu/i;->c:Lj0/k$d;

    if-eqz v0, :cond_0

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {v0, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    :cond_0
    const/4 p1, 0x0

    iput-object p1, p0, Lu/i;->c:Lj0/k$d;

    return-void
.end method

.method private final a0()V
    .locals 2

    iget-boolean v0, p0, Lu/i;->g:Z

    const/4 v1, 0x0

    if-eqz v0, :cond_0

    iput-boolean v1, p0, Lu/i;->h:Z

    :cond_0
    iget-boolean v0, p0, Lu/i;->e:Z

    if-eqz v0, :cond_1

    iput-boolean v1, p0, Lu/i;->f:Z

    :cond_1
    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0}, Landroid/speech/tts/TextToSpeech;->stop()I

    return-void
.end method

.method public static synthetic b(Lu/i;I)V
    .locals 0

    invoke-static {p0, p1}, Lu/i;->Z(Lu/i;I)V

    return-void
.end method

.method public static synthetic c(Lu/i;Lj0/j;Lj0/k$d;)V
    .locals 0

    invoke-static {p0, p1, p2}, Lu/i;->P(Lu/i;Lj0/j;Lj0/k$d;)V

    return-void
.end method

.method private static final c0(Lu/i;I)V
    .locals 1

    const-string v0, "this$0"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    iget-object p0, p0, Lu/i;->d:Lj0/k$d;

    if-eqz p0, :cond_0

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {p0, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    :cond_0
    return-void
.end method

.method public static synthetic d(Lu/i;I)V
    .locals 0

    invoke-static {p0, p1}, Lu/i;->c0(Lu/i;I)V

    return-void
.end method

.method private final d0(Ljava/lang/String;Ljava/lang/String;)V
    .locals 7

    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "toString(...)"

    invoke-static {v0, v1}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    iget-object v1, p0, Lu/i;->n:Landroid/os/Bundle;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "STF_"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    const-string v4, "utteranceId"

    invoke-virtual {v1, v4, v2}, Landroid/os/BaseBundle;->putString(Ljava/lang/String;Ljava/lang/String;)V

    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1e

    if-lt v1, v2, :cond_4

    iget-object v1, p0, Lu/i;->i:Landroid/content/Context;

    const/4 v2, 0x0

    if-eqz v1, :cond_0

    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    goto :goto_0

    :cond_0
    move-object v1, v2

    :goto_0
    new-instance v4, Landroid/content/ContentValues;

    invoke-direct {v4}, Landroid/content/ContentValues;-><init>()V

    const-string v5, "_display_name"

    invoke-virtual {v4, v5, p2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    const-string v5, "mime_type"

    const-string v6, "audio/wav"

    invoke-virtual {v4, v5, v6}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    sget-object v5, Landroid/os/Environment;->DIRECTORY_MUSIC:Ljava/lang/String;

    const-string v6, "relative_path"

    invoke-virtual {v4, v6, v5}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    if-eqz v1, :cond_1

    sget-object v5, Landroid/provider/MediaStore$Audio$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v1, v5, v4}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    move-result-object v4

    goto :goto_1

    :cond_1
    move-object v4, v2

    :goto_1
    if-eqz v1, :cond_2

    invoke-static {v4}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    const-string v5, "rw"

    invoke-virtual {v1, v4, v5}, Landroid/content/ContentResolver;->openFileDescriptor(Landroid/net/Uri;Ljava/lang/String;)Landroid/os/ParcelFileDescriptor;

    move-result-object v1

    goto :goto_2

    :cond_2
    move-object v1, v2

    :goto_2
    iput-object v1, p0, Lu/i;->w:Landroid/os/ParcelFileDescriptor;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    if-eqz v4, :cond_3

    invoke-virtual {v4}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v2

    :cond_3
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    sget-char v2, Ljava/io/File;->separatorChar:C

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget-object v2, p0, Lu/i;->n:Landroid/os/Bundle;

    invoke-static {v2}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget-object v4, p0, Lu/i;->w:Landroid/os/ParcelFileDescriptor;

    invoke-static {v4}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, p1, v2, v4, v0}, Lu/a;->a(Landroid/speech/tts/TextToSpeech;Ljava/lang/CharSequence;Landroid/os/Bundle;Landroid/os/ParcelFileDescriptor;Ljava/lang/String;)I

    move-result p1

    goto :goto_3

    :cond_4
    sget-object v1, Landroid/os/Environment;->DIRECTORY_MUSIC:Ljava/lang/String;

    invoke-static {v1}, Landroid/os/Environment;->getExternalStoragePublicDirectory(Ljava/lang/String;)Ljava/io/File;

    move-result-object v1

    new-instance v2, Ljava/io/File;

    invoke-direct {v2, v1, p2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object p2

    const-string v1, "getPath(...)"

    invoke-static {p2, v1}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget-object v4, p0, Lu/i;->n:Landroid/os/Bundle;

    invoke-static {v4}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, p1, v4, v2, v0}, Landroid/speech/tts/TextToSpeech;->synthesizeToFile(Ljava/lang/CharSequence;Landroid/os/Bundle;Ljava/io/File;Ljava/lang/String;)I

    move-result p1

    :goto_3
    if-nez p1, :cond_5

    iget-object p1, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Successfully created file : "

    goto :goto_4

    :cond_5
    iget-object p1, p0, Lu/i;->k:Ljava/lang/String;

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Failed creating file : "

    :goto_4
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-static {p1, p2}, Lw/b;->a(Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method public static synthetic e(Lu/i;I)V
    .locals 0

    invoke-static {p0, p1}, Lu/i;->A(Lu/i;I)V

    return-void
.end method

.method public static synthetic f(Lu/i;I)V
    .locals 0

    invoke-static {p0, p1}, Lu/i;->O(Lu/i;I)V

    return-void
.end method

.method public static synthetic g(Lu/i;Lj0/j;Lj0/k$d;)V
    .locals 0

    invoke-static {p0, p1, p2}, Lu/i;->Q(Lu/i;Lj0/j;Lj0/k$d;)V

    return-void
.end method

.method public static synthetic j(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 0

    invoke-static {p0, p1, p2}, Lu/i;->K(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method public static final synthetic k(Lu/i;Z)V
    .locals 0

    invoke-direct {p0, p1}, Lu/i;->z(Z)V

    return-void
.end method

.method public static final synthetic l(Lu/i;)Z
    .locals 0

    iget-boolean p0, p0, Lu/i;->e:Z

    return p0
.end method

.method public static final synthetic m(Lu/i;)Z
    .locals 0

    iget-boolean p0, p0, Lu/i;->g:Z

    return p0
.end method

.method public static final synthetic n(Lu/i;)I
    .locals 0

    iget p0, p0, Lu/i;->t:I

    return p0
.end method

.method public static final synthetic o(Lu/i;)Ljava/lang/String;
    .locals 0

    iget-object p0, p0, Lu/i;->k:Ljava/lang/String;

    return-object p0
.end method

.method public static final synthetic p(Lu/i;)Ljava/util/HashMap;
    .locals 0

    iget-object p0, p0, Lu/i;->m:Ljava/util/HashMap;

    return-object p0
.end method

.method public static final synthetic q(Lu/i;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lu/i;->J(Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method public static final synthetic r(Lu/i;)Z
    .locals 0

    iget-boolean p0, p0, Lu/i;->s:Z

    return p0
.end method

.method public static final synthetic s(Lu/i;I)V
    .locals 0

    iput p1, p0, Lu/i;->p:I

    return-void
.end method

.method public static final synthetic t(Lu/i;Ljava/lang/String;)V
    .locals 0

    iput-object p1, p0, Lu/i;->r:Ljava/lang/String;

    return-void
.end method

.method public static final synthetic u(Lu/i;Z)V
    .locals 0

    iput-boolean p1, p0, Lu/i;->s:Z

    return-void
.end method

.method public static final synthetic v(Lu/i;Z)V
    .locals 0

    iput-boolean p1, p0, Lu/i;->f:Z

    return-void
.end method

.method public static final synthetic w(Lu/i;Z)V
    .locals 0

    iput-boolean p1, p0, Lu/i;->h:Z

    return-void
.end method

.method private final x(Ljava/util/List;)Ljava/util/Map;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-direct {p0, v1}, Lu/i;->M(Ljava/lang/String;)Z

    move-result v2

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_0

    :cond_0
    return-object v0
.end method

.method private final y(Lj0/k$d;)V
    .locals 2

    iget-object v0, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget-object v1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {v1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v1}, Landroid/speech/tts/TextToSpeech;->getDefaultVoice()Landroid/speech/tts/Voice;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/speech/tts/TextToSpeech;->setVoice(Landroid/speech/tts/Voice;)I

    const/4 v0, 0x1

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-interface {p1, v0}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method private final z(Z)V
    .locals 1

    iget-object v0, p0, Lu/i;->w:Landroid/os/ParcelFileDescriptor;

    if-eqz v0, :cond_1

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    if-eqz p1, :cond_0

    const-string p1, "Error synthesizing TTS to file"

    invoke-virtual {v0, p1}, Landroid/os/ParcelFileDescriptor;->closeWithError(Ljava/lang/String;)V

    goto :goto_0

    :cond_0
    invoke-virtual {v0}, Landroid/os/ParcelFileDescriptor;->close()V

    :cond_1
    :goto_0
    return-void
.end method


# virtual methods
.method public final Y(I)V
    .locals 2

    const/4 v0, 0x0

    iput-boolean v0, p0, Lu/i;->f:Z

    iget-object v0, p0, Lu/i;->a:Landroid/os/Handler;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    new-instance v1, Lu/d;

    invoke-direct {v1, p0, p1}, Lu/d;-><init>(Lu/i;I)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method public a(Lb0/a$b;)V
    .locals 1

    const-string v0, "binding"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0}, Lu/i;->a0()V

    iget-object p1, p0, Lu/i;->j:Landroid/speech/tts/TextToSpeech;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {p1}, Landroid/speech/tts/TextToSpeech;->shutdown()V

    const/4 p1, 0x0

    iput-object p1, p0, Lu/i;->i:Landroid/content/Context;

    iget-object v0, p0, Lu/i;->b:Lj0/k;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-virtual {v0, p1}, Lj0/k;->e(Lj0/k$c;)V

    iput-object p1, p0, Lu/i;->b:Lj0/k;

    return-void
.end method

.method public final b0(I)V
    .locals 2

    const/4 v0, 0x0

    iput-boolean v0, p0, Lu/i;->h:Z

    iget-object v0, p0, Lu/i;->a:Landroid/os/Handler;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    new-instance v1, Lu/e;

    invoke-direct {v1, p0, p1}, Lu/e;-><init>(Lu/i;I)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method public h(Lj0/j;Lj0/k$d;)V
    .locals 5

    const-string v0, "call"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "result"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    monitor-enter p0

    :try_start_0
    iget-object v0, p0, Lu/i;->u:Ljava/lang/Integer;

    if-nez v0, :cond_0

    new-instance v0, Lu/g;

    invoke-direct {v0, p0, p1, p2}, Lu/g;-><init>(Lu/i;Lj0/j;Lj0/k$d;)V

    iget-object p1, p0, Lu/i;->l:Ljava/util/ArrayList;

    invoke-virtual {p1, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    monitor-exit p0

    return-void

    :cond_0
    :try_start_1
    sget-object v0, Lq0/q;->a:Lq0/q;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    monitor-exit p0

    iget-object v0, p1, Lj0/j;->a:Ljava/lang/String;

    if-eqz v0, :cond_22

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v1

    const/4 v2, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x1

    sparse-switch v1, :sswitch_data_0

    goto/16 :goto_6

    :sswitch_0
    const-string p1, "getMaxSpeechInputLength"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_1

    goto/16 :goto_6

    :cond_1
    invoke-direct {p0}, Lu/i;->F()I

    move-result p1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    goto/16 :goto_5

    :sswitch_1
    const-string p1, "getLanguages"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_2

    goto/16 :goto_6

    :cond_2
    invoke-direct {p0, p2}, Lu/i;->E(Lj0/k$d;)V

    goto/16 :goto_7

    :sswitch_2
    const-string v1, "setVoice"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_3

    goto/16 :goto_6

    :cond_3
    invoke-virtual {p1}, Lj0/j;->b()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/HashMap;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-direct {p0, p1, p2}, Lu/i;->V(Ljava/util/HashMap;Lj0/k$d;)V

    goto/16 :goto_7

    :sswitch_3
    const-string v1, "setPitch"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4

    goto/16 :goto_6

    :cond_4
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result p1

    invoke-direct {p0, p1, p2}, Lu/i;->T(FLj0/k$d;)V

    goto/16 :goto_7

    :sswitch_4
    const-string v1, "synthesizeToFile"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_5

    goto/16 :goto_6

    :cond_5
    const-string v0, "text"

    invoke-virtual {p1, v0}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    iget-boolean v1, p0, Lu/i;->h:Z

    if-eqz v1, :cond_6

    :goto_0
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void

    :cond_6
    const-string v1, "fileName"

    invoke-virtual {p1, v1}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-direct {p0, v0, p1}, Lu/i;->d0(Ljava/lang/String;Ljava/lang/String;)V

    iget-boolean p1, p0, Lu/i;->g:Z

    if-eqz p1, :cond_21

    iput-boolean v4, p0, Lu/i;->h:Z

    iput-object p2, p0, Lu/i;->d:Lj0/k$d;

    goto/16 :goto_7

    :sswitch_5
    const-string v1, "setSpeechRate"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_7

    goto/16 :goto_6

    :cond_7
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result p1

    const/high16 v0, 0x40000000    # 2.0f

    mul-float p1, p1, v0

    invoke-direct {p0, p1}, Lu/i;->U(F)V

    goto/16 :goto_4

    :sswitch_6
    const-string v1, "isLanguageInstalled"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_8

    goto/16 :goto_6

    :cond_8
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Lu/i;->M(Ljava/lang/String;)Z

    move-result p1

    goto/16 :goto_1

    :sswitch_7
    const-string p1, "getSpeechRateValidRange"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_9

    goto/16 :goto_6

    :cond_9
    invoke-direct {p0, p2}, Lu/i;->G(Lj0/k$d;)V

    goto/16 :goto_7

    :sswitch_8
    const-string p1, "getDefaultVoice"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_a

    goto/16 :goto_6

    :cond_a
    invoke-direct {p0, p2}, Lu/i;->C(Lj0/k$d;)V

    goto/16 :goto_7

    :sswitch_9
    const-string p1, "getVoices"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_b

    goto/16 :goto_6

    :cond_b
    invoke-direct {p0, p2}, Lu/i;->H(Lj0/k$d;)V

    goto/16 :goto_7

    :sswitch_a
    const-string v1, "setSilence"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_c

    goto/16 :goto_6

    :cond_c
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p1

    iput p1, p0, Lu/i;->o:I

    goto/16 :goto_7

    :sswitch_b
    const-string v1, "setVolume"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_d

    goto/16 :goto_6

    :cond_d
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F

    move-result p1

    invoke-direct {p0, p1, p2}, Lu/i;->W(FLj0/k$d;)V

    goto/16 :goto_7

    :sswitch_c
    const-string v1, "setLanguage"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_e

    goto/16 :goto_6

    :cond_e
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1, p2}, Lu/i;->S(Ljava/lang/String;Lj0/k$d;)V

    goto/16 :goto_7

    :sswitch_d
    const-string v1, "isLanguageAvailable"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_f

    goto/16 :goto_6

    :cond_f
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/util/Locale;->forLanguageTag(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object p1

    const-string v0, "forLanguageTag(...)"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0, p1}, Lu/i;->L(Ljava/util/Locale;)Z

    move-result p1

    :goto_1
    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    goto/16 :goto_5

    :sswitch_e
    const-string v1, "setEngine"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_10

    goto/16 :goto_6

    :cond_10
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1, p2}, Lu/i;->R(Ljava/lang/String;Lj0/k$d;)V

    goto/16 :goto_7

    :sswitch_f
    const-string v1, "speak"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_11

    goto/16 :goto_6

    :cond_11
    iget-object v0, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    iget-object v1, p0, Lu/i;->r:Ljava/lang/String;

    if-nez v1, :cond_12

    iput-object v0, p0, Lu/i;->r:Ljava/lang/String;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iput-object v0, p0, Lu/i;->q:Ljava/lang/String;

    :cond_12
    iget-boolean v1, p0, Lu/i;->s:Z

    if-eqz v1, :cond_14

    iget-object v1, p0, Lu/i;->q:Ljava/lang/String;

    invoke-static {v1, v0}, Lkotlin/jvm/internal/i;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_13

    iget-object v0, p0, Lu/i;->r:Ljava/lang/String;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    goto :goto_2

    :cond_13
    iput-object v0, p0, Lu/i;->r:Ljava/lang/String;

    invoke-static {v0}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iput-object v0, p0, Lu/i;->q:Ljava/lang/String;

    iput v3, p0, Lu/i;->p:I

    :cond_14
    :goto_2
    iget-boolean v1, p0, Lu/i;->f:Z

    if-eqz v1, :cond_15

    iget v1, p0, Lu/i;->t:I

    if-nez v1, :cond_15

    goto/16 :goto_0

    :cond_15
    invoke-direct {p0, v0}, Lu/i;->X(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_16

    monitor-enter p0

    :try_start_2
    new-instance v0, Lu/h;

    invoke-direct {v0, p0, p1, p2}, Lu/h;-><init>(Lu/i;Lj0/j;Lj0/k$d;)V

    iget-object p1, p0, Lu/i;->l:Ljava/util/ArrayList;

    invoke-virtual {p1, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    monitor-exit p0

    return-void

    :catchall_0
    move-exception p1

    monitor-exit p0

    throw p1

    :cond_16
    iget-boolean p1, p0, Lu/i;->e:Z

    if-eqz p1, :cond_21

    iget p1, p0, Lu/i;->t:I

    if-nez p1, :cond_21

    iput-boolean v4, p0, Lu/i;->f:Z

    iput-object p2, p0, Lu/i;->c:Lj0/k$d;

    goto/16 :goto_7

    :sswitch_10
    const-string p1, "pause"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_17

    goto/16 :goto_6

    :cond_17
    iput-boolean v4, p0, Lu/i;->s:Z

    iget-object p1, p0, Lu/i;->r:Ljava/lang/String;

    if-eqz p1, :cond_18

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    iget v0, p0, Lu/i;->p:I

    invoke-virtual {p1, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p1

    const-string v0, "this as java.lang.String).substring(startIndex)"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    iput-object p1, p0, Lu/i;->r:Ljava/lang/String;

    :cond_18
    invoke-direct {p0}, Lu/i;->a0()V

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    iget-object p1, p0, Lu/i;->c:Lj0/k$d;

    if-eqz p1, :cond_23

    goto :goto_3

    :sswitch_11
    const-string p1, "stop"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_19

    goto/16 :goto_6

    :cond_19
    iput-boolean v3, p0, Lu/i;->s:Z

    iput-object v2, p0, Lu/i;->r:Ljava/lang/String;

    invoke-direct {p0}, Lu/i;->a0()V

    iput v3, p0, Lu/i;->p:I

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    iget-object p1, p0, Lu/i;->c:Lj0/k$d;

    if-eqz p1, :cond_23

    :goto_3
    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p2

    invoke-interface {p1, p2}, Lj0/k$d;->a(Ljava/lang/Object;)V

    iput-object v2, p0, Lu/i;->c:Lj0/k$d;

    goto/16 :goto_7

    :sswitch_12
    const-string v1, "setQueueMode"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1a

    goto/16 :goto_6

    :cond_1a
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p1

    iput p1, p0, Lu/i;->t:I

    goto/16 :goto_4

    :sswitch_13
    const-string p1, "getDefaultEngine"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_1b

    goto/16 :goto_6

    :cond_1b
    invoke-direct {p0, p2}, Lu/i;->B(Lj0/k$d;)V

    goto/16 :goto_7

    :sswitch_14
    const-string p1, "getEngines"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_1c

    goto/16 :goto_6

    :cond_1c
    invoke-direct {p0, p2}, Lu/i;->D(Lj0/k$d;)V

    goto :goto_7

    :sswitch_15
    const-string v1, "awaitSynthCompletion"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1d

    goto :goto_6

    :cond_1d
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Boolean;->parseBoolean(Ljava/lang/String;)Z

    move-result p1

    iput-boolean p1, p0, Lu/i;->g:Z

    goto :goto_4

    :sswitch_16
    const-string p1, "clearVoice"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_1e

    goto :goto_6

    :cond_1e
    invoke-direct {p0, p2}, Lu/i;->y(Lj0/k$d;)V

    goto :goto_7

    :sswitch_17
    const-string p1, "setSharedInstance"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_21

    goto :goto_6

    :sswitch_18
    const-string v1, "areLanguagesInstalled"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1f

    goto :goto_6

    :cond_1f
    invoke-virtual {p1}, Lj0/j;->b()Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/List;

    invoke-static {p1}, Lkotlin/jvm/internal/i;->b(Ljava/lang/Object;)V

    invoke-direct {p0, p1}, Lu/i;->x(Ljava/util/List;)Ljava/util/Map;

    move-result-object p1

    goto :goto_5

    :sswitch_19
    const-string v1, "awaitSpeakCompletion"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_20

    goto :goto_6

    :cond_20
    iget-object p1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Ljava/lang/Boolean;->parseBoolean(Ljava/lang/String;)Z

    move-result p1

    iput-boolean p1, p0, Lu/i;->e:Z

    :cond_21
    :goto_4
    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    :goto_5
    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    goto :goto_7

    :cond_22
    :goto_6
    invoke-interface {p2}, Lj0/k$d;->c()V

    :cond_23
    :goto_7
    return-void

    :catchall_1
    move-exception p1

    monitor-exit p0

    throw p1

    :sswitch_data_0
    .sparse-switch
        -0x511bb6e8 -> :sswitch_19
        -0x493dc8ed -> :sswitch_18
        -0x44c85ae4 -> :sswitch_17
        -0x2c2edd1b -> :sswitch_16
        -0x2a3337fe -> :sswitch_15
        -0x21cb75c5 -> :sswitch_14
        -0x20d2fbd3 -> :sswitch_13
        -0xbeff7ee -> :sswitch_12
        0x360802 -> :sswitch_11
        0x65825f6 -> :sswitch_10
        0x688ffd2 -> :sswitch_f
        0xae45144 -> :sswitch_e
        0x10844647 -> :sswitch_d
        0x166531da -> :sswitch_c
        0x27f73e1c -> :sswitch_b
        0x2df97ddf -> :sswitch_a
        0x34c06877 -> :sswitch_9
        0x39af6de7 -> :sswitch_8
        0x39ef4599 -> :sswitch_7
        0x3dfdf2f8 -> :sswitch_6
        0x40cf8ee4 -> :sswitch_5
        0x4f15f761 -> :sswitch_4
        0x538783fe -> :sswitch_3
        0x53dea1f0 -> :sswitch_2
        0x59ed4965 -> :sswitch_1
        0x67d6e880 -> :sswitch_0
    .end sparse-switch
.end method

.method public i(Lb0/a$b;)V
    .locals 2

    const-string v0, "binding"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p1}, Lb0/a$b;->b()Lj0/c;

    move-result-object v0

    const-string v1, "getBinaryMessenger(...)"

    invoke-static {v0, v1}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p1}, Lb0/a$b;->a()Landroid/content/Context;

    move-result-object p1

    const-string v1, "getApplicationContext(...)"

    invoke-static {p1, v1}, Lkotlin/jvm/internal/i;->d(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0, v0, p1}, Lu/i;->I(Lj0/c;Landroid/content/Context;)V

    return-void
.end method
