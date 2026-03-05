.class public Lio/flutter/plugin/platform/h;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugin/platform/h$d;
    }
.end annotation


# instance fields
.field private final a:Landroid/app/Activity;

.field private final b:Li0/j;

.field private final c:Lio/flutter/plugin/platform/h$d;

.field private d:Li0/j$j;

.field private e:I

.field final f:Li0/j$h;


# direct methods
.method public constructor <init>(Landroid/app/Activity;Li0/j;Lio/flutter/plugin/platform/h$d;)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lio/flutter/plugin/platform/h$a;

    invoke-direct {v0, p0}, Lio/flutter/plugin/platform/h$a;-><init>(Lio/flutter/plugin/platform/h;)V

    iput-object v0, p0, Lio/flutter/plugin/platform/h;->f:Li0/j$h;

    iput-object p1, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    iput-object p2, p0, Lio/flutter/plugin/platform/h;->b:Li0/j;

    invoke-virtual {p2, v0}, Li0/j;->l(Li0/j$h;)V

    iput-object p3, p0, Lio/flutter/plugin/platform/h;->c:Lio/flutter/plugin/platform/h$d;

    const/16 p1, 0x500

    iput p1, p0, Lio/flutter/plugin/platform/h;->e:I

    return-void
.end method

.method private A(Ljava/util/List;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Li0/j$l;",
            ">;)V"
        }
    .end annotation

    invoke-interface {p1}, Ljava/util/List;->size()I

    move-result v0

    if-nez v0, :cond_0

    const/16 v0, 0x1706

    goto :goto_0

    :cond_0
    const/16 v0, 0x706

    :goto_0
    const/4 v1, 0x0

    :goto_1
    invoke-interface {p1}, Ljava/util/List;->size()I

    move-result v2

    if-ge v1, v2, :cond_3

    invoke-interface {p1, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Li0/j$l;

    sget-object v3, Lio/flutter/plugin/platform/h$c;->b:[I

    invoke-virtual {v2}, Ljava/lang/Enum;->ordinal()I

    move-result v2

    aget v2, v3, v2

    const/4 v3, 0x1

    if-eq v2, v3, :cond_2

    const/4 v3, 0x2

    if-eq v2, v3, :cond_1

    goto :goto_2

    :cond_1
    and-int/lit16 v0, v0, -0x201

    and-int/lit8 v0, v0, -0x3

    goto :goto_2

    :cond_2
    and-int/lit8 v0, v0, -0x5

    :goto_2
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    :cond_3
    iput v0, p0, Lio/flutter/plugin/platform/h;->e:I

    invoke-virtual {p0}, Lio/flutter/plugin/platform/h;->E()V

    return-void
.end method

.method private B(I)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {v0, p1}, Landroid/app/Activity;->setRequestedOrientation(I)V

    return-void
.end method

.method private C(Li0/j$j;)V
    .locals 9
    .annotation build Landroid/annotation/TargetApi;
        value = 0x15
    .end annotation

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v1

    new-instance v2, Landroidx/core/view/b0;

    invoke-direct {v2, v0, v1}, Landroidx/core/view/b0;-><init>(Landroid/view/Window;Landroid/view/View;)V

    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1e

    if-ge v1, v3, :cond_0

    const/high16 v3, -0x80000000

    invoke-virtual {v0, v3}, Landroid/view/Window;->addFlags(I)V

    const/high16 v3, 0xc000000

    invoke-virtual {v0, v3}, Landroid/view/Window;->clearFlags(I)V

    :cond_0
    const/16 v3, 0x17

    const/4 v4, 0x0

    const/4 v5, 0x2

    const/4 v6, 0x1

    if-lt v1, v3, :cond_4

    iget-object v3, p1, Li0/j$j;->b:Li0/j$d;

    if-eqz v3, :cond_3

    sget-object v7, Lio/flutter/plugin/platform/h$c;->c:[I

    invoke-virtual {v3}, Ljava/lang/Enum;->ordinal()I

    move-result v3

    aget v3, v7, v3

    if-eq v3, v6, :cond_2

    if-eq v3, v5, :cond_1

    goto :goto_0

    :cond_1
    invoke-virtual {v2, v4}, Landroidx/core/view/b0;->b(Z)V

    goto :goto_0

    :cond_2
    invoke-virtual {v2, v6}, Landroidx/core/view/b0;->b(Z)V

    :cond_3
    :goto_0
    iget-object v3, p1, Li0/j$j;->a:Ljava/lang/Integer;

    if-eqz v3, :cond_4

    invoke-virtual {v3}, Ljava/lang/Integer;->intValue()I

    move-result v3

    invoke-virtual {v0, v3}, Landroid/view/Window;->setStatusBarColor(I)V

    :cond_4
    iget-object v3, p1, Li0/j$j;->c:Ljava/lang/Boolean;

    const/16 v7, 0x1d

    if-eqz v3, :cond_5

    if-lt v1, v7, :cond_5

    invoke-virtual {v3}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v3

    invoke-static {v0, v3}, Lio/flutter/plugin/platform/e;->a(Landroid/view/Window;Z)V

    :cond_5
    const/16 v3, 0x1a

    if-lt v1, v3, :cond_9

    iget-object v3, p1, Li0/j$j;->e:Li0/j$d;

    if-eqz v3, :cond_8

    sget-object v8, Lio/flutter/plugin/platform/h$c;->c:[I

    invoke-virtual {v3}, Ljava/lang/Enum;->ordinal()I

    move-result v3

    aget v3, v8, v3

    if-eq v3, v6, :cond_7

    if-eq v3, v5, :cond_6

    goto :goto_1

    :cond_6
    invoke-virtual {v2, v4}, Landroidx/core/view/b0;->a(Z)V

    goto :goto_1

    :cond_7
    invoke-virtual {v2, v6}, Landroidx/core/view/b0;->a(Z)V

    :cond_8
    :goto_1
    iget-object v2, p1, Li0/j$j;->d:Ljava/lang/Integer;

    if-eqz v2, :cond_9

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    invoke-virtual {v0, v2}, Landroid/view/Window;->setNavigationBarColor(I)V

    :cond_9
    iget-object v2, p1, Li0/j$j;->f:Ljava/lang/Integer;

    if-eqz v2, :cond_a

    const/16 v3, 0x1c

    if-lt v1, v3, :cond_a

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    invoke-static {v0, v2}, Lio/flutter/plugin/platform/f;->a(Landroid/view/Window;I)V

    :cond_a
    iget-object v2, p1, Li0/j$j;->g:Ljava/lang/Boolean;

    if-eqz v2, :cond_b

    if-lt v1, v7, :cond_b

    invoke-virtual {v2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    invoke-static {v0, v1}, Lio/flutter/plugin/platform/g;->a(Landroid/view/Window;Z)V

    :cond_b
    iput-object p1, p0, Lio/flutter/plugin/platform/h;->d:Li0/j$j;

    return-void
.end method

.method private D(Ljava/lang/String;)V
    .locals 2

    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    const-string v1, "android.intent.action.SEND"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    const-string v1, "text/plain"

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    const-string v1, "android.intent.extra.TEXT"

    invoke-virtual {v0, v1, p1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    iget-object p1, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Landroid/content/Intent;->createChooser(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/app/Activity;->startActivity(Landroid/content/Intent;)V

    return-void
.end method

.method static synthetic a(Lio/flutter/plugin/platform/h;Li0/j$i;)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->s(Li0/j$i;)V

    return-void
.end method

.method static synthetic b(Lio/flutter/plugin/platform/h;I)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->B(I)V

    return-void
.end method

.method static synthetic c(Lio/flutter/plugin/platform/h;Li0/j$e;)Ljava/lang/CharSequence;
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->r(Li0/j$e;)Ljava/lang/CharSequence;

    move-result-object p0

    return-object p0
.end method

.method static synthetic d(Lio/flutter/plugin/platform/h;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->v(Ljava/lang/String;)V

    return-void
.end method

.method static synthetic e(Lio/flutter/plugin/platform/h;)Z
    .locals 0

    invoke-direct {p0}, Lio/flutter/plugin/platform/h;->p()Z

    move-result p0

    return p0
.end method

.method static synthetic f(Lio/flutter/plugin/platform/h;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->D(Ljava/lang/String;)V

    return-void
.end method

.method static synthetic g(Lio/flutter/plugin/platform/h;)Li0/j;
    .locals 0

    iget-object p0, p0, Lio/flutter/plugin/platform/h;->b:Li0/j;

    return-object p0
.end method

.method static synthetic h(Lio/flutter/plugin/platform/h;Li0/j$c;)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->x(Li0/j$c;)V

    return-void
.end method

.method static synthetic i(Lio/flutter/plugin/platform/h;Ljava/util/List;)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->A(Ljava/util/List;)V

    return-void
.end method

.method static synthetic j(Lio/flutter/plugin/platform/h;Li0/j$k;)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->z(Li0/j$k;)V

    return-void
.end method

.method static synthetic k(Lio/flutter/plugin/platform/h;)V
    .locals 0

    invoke-direct {p0}, Lio/flutter/plugin/platform/h;->y()V

    return-void
.end method

.method static synthetic l(Lio/flutter/plugin/platform/h;)V
    .locals 0

    invoke-direct {p0}, Lio/flutter/plugin/platform/h;->u()V

    return-void
.end method

.method static synthetic m(Lio/flutter/plugin/platform/h;Li0/j$j;)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->C(Li0/j$j;)V

    return-void
.end method

.method static synthetic n(Lio/flutter/plugin/platform/h;Z)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugin/platform/h;->w(Z)V

    return-void
.end method

.method static synthetic o(Lio/flutter/plugin/platform/h;)V
    .locals 0

    invoke-direct {p0}, Lio/flutter/plugin/platform/h;->t()V

    return-void
.end method

.method private p()Z
    .locals 3

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    const-string v1, "clipboard"

    invoke-virtual {v0, v1}, Landroid/app/Activity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/ClipboardManager;

    invoke-virtual {v0}, Landroid/content/ClipboardManager;->hasPrimaryClip()Z

    move-result v1

    const/4 v2, 0x0

    if-nez v1, :cond_0

    return v2

    :cond_0
    invoke-virtual {v0}, Landroid/content/ClipboardManager;->getPrimaryClipDescription()Landroid/content/ClipDescription;

    move-result-object v0

    if-nez v0, :cond_1

    return v2

    :cond_1
    const-string v1, "text/*"

    invoke-virtual {v0, v1}, Landroid/content/ClipDescription;->hasMimeType(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method private r(Li0/j$e;)Ljava/lang/CharSequence;
    .locals 6

    const-string v0, "PlatformPlugin"

    iget-object v1, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    const-string v2, "clipboard"

    invoke-virtual {v1, v2}, Landroid/app/Activity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/content/ClipboardManager;

    invoke-virtual {v1}, Landroid/content/ClipboardManager;->hasPrimaryClip()Z

    move-result v2

    const/4 v3, 0x0

    if-nez v2, :cond_0

    return-object v3

    :cond_0
    :try_start_0
    invoke-virtual {v1}, Landroid/content/ClipboardManager;->getPrimaryClip()Landroid/content/ClipData;

    move-result-object v1

    if-nez v1, :cond_1

    return-object v3

    :cond_1
    if-eqz p1, :cond_3

    sget-object v2, Li0/j$e;->e:Li0/j$e;

    if-ne p1, v2, :cond_2

    goto :goto_0

    :cond_2
    return-object v3

    :cond_3
    :goto_0
    const/4 p1, 0x0

    invoke-virtual {v1, p1}, Landroid/content/ClipData;->getItemAt(I)Landroid/content/ClipData$Item;

    move-result-object p1

    invoke-virtual {p1}, Landroid/content/ClipData$Item;->getText()Ljava/lang/CharSequence;

    move-result-object v1
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_3
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_2
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1

    if-nez v1, :cond_6

    :try_start_1
    invoke-virtual {p1}, Landroid/content/ClipData$Item;->getUri()Landroid/net/Uri;

    move-result-object v2

    if-nez v2, :cond_4

    const-string p1, "Clipboard item contained no textual content nor a URI to retrieve it from."

    invoke-static {v0, p1}, Lw/b;->g(Ljava/lang/String;Ljava/lang/String;)V

    return-object v3

    :cond_4
    invoke-virtual {v2}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v4

    const-string v5, "content"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-nez v5, :cond_5

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Clipboard item contains a Uri with scheme \'"

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "\'that is unhandled."

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Lw/b;->g(Ljava/lang/String;Ljava/lang/String;)V

    return-object v3

    :cond_5
    iget-object v4, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {v4}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v4

    const-string v5, "text/*"

    invoke-virtual {v4, v2, v5, v3}, Landroid/content/ContentResolver;->openTypedAssetFileDescriptor(Landroid/net/Uri;Ljava/lang/String;Landroid/os/Bundle;)Landroid/content/res/AssetFileDescriptor;

    move-result-object v2

    iget-object v4, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {p1, v4}, Landroid/content/ClipData$Item;->coerceToText(Landroid/content/Context;)Ljava/lang/CharSequence;

    move-result-object v1

    if-eqz v2, :cond_6

    invoke-virtual {v2}, Landroid/content/res/AssetFileDescriptor;->close()V
    :try_end_1
    .catch Ljava/lang/SecurityException; {:try_start_1 .. :try_end_1} :catch_3
    .catch Ljava/io/FileNotFoundException; {:try_start_1 .. :try_end_1} :catch_2
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_1

    :catch_0
    move-exception p1

    move-object v3, v1

    goto :goto_2

    :cond_6
    :goto_1
    return-object v1

    :catch_1
    move-exception p1

    :goto_2
    const-string v1, "Failed to close AssetFileDescriptor while trying to read text from URI."

    invoke-static {v0, v1, p1}, Lw/b;->h(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    return-object v3

    :catch_2
    const-string p1, "Clipboard text was unable to be received from content URI."

    invoke-static {v0, p1}, Lw/b;->g(Ljava/lang/String;Ljava/lang/String;)V

    return-object v3

    :catch_3
    move-exception p1

    const-string v1, "Attempted to get clipboard data that requires additional permission(s).\nSee the exception details for which permission(s) are required, and consider adding them to your Android Manifest as described in:\nhttps://developer.android.com/guide/topics/permissions/overview"

    invoke-static {v0, v1, p1}, Lw/b;->h(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    return-object v3
.end method

.method private s(Li0/j$i;)V
    .locals 1

    sget-object v0, Li0/j$i;->e:Li0/j$i;

    if-ne p1, v0, :cond_0

    iget-object p1, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {p1}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object p1

    invoke-virtual {p1}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object p1

    const/4 v0, 0x0

    invoke-virtual {p1, v0}, Landroid/view/View;->playSoundEffect(I)V

    :cond_0
    return-void
.end method

.method private t()V
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->c:Lio/flutter/plugin/platform/h$d;

    if-eqz v0, :cond_0

    invoke-interface {v0}, Lio/flutter/plugin/platform/h$d;->b()Z

    move-result v0

    if-eqz v0, :cond_0

    return-void

    :cond_0
    iget-object v0, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    instance-of v1, v0, Landroidx/activity/b;

    if-nez v1, :cond_1

    invoke-virtual {v0}, Landroid/app/Activity;->finish()V

    return-void

    :cond_1
    check-cast v0, Landroidx/activity/b;

    invoke-interface {v0}, Landroidx/activity/b;->j()Landroidx/activity/OnBackPressedDispatcher;

    const/4 v0, 0x0

    throw v0
.end method

.method private u()V
    .locals 0

    invoke-virtual {p0}, Lio/flutter/plugin/platform/h;->E()V

    return-void
.end method

.method private v(Ljava/lang/String;)V
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    const-string v1, "clipboard"

    invoke-virtual {v0, v1}, Landroid/app/Activity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/content/ClipboardManager;

    const-string v1, "text label?"

    invoke-static {v1, p1}, Landroid/content/ClipData;->newPlainText(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Landroid/content/ClipData;

    move-result-object p1

    invoke-virtual {v0, p1}, Landroid/content/ClipboardManager;->setPrimaryClip(Landroid/content/ClipData;)V

    return-void
.end method

.method private w(Z)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->c:Lio/flutter/plugin/platform/h$d;

    if-eqz v0, :cond_0

    invoke-interface {v0, p1}, Lio/flutter/plugin/platform/h$d;->g(Z)V

    :cond_0
    return-void
.end method

.method private x(Li0/j$c;)V
    .locals 7

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1c

    if-ge v0, v1, :cond_0

    const/16 v2, 0x15

    if-le v0, v2, :cond_0

    iget-object v2, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    new-instance v3, Landroid/app/ActivityManager$TaskDescription;

    iget-object v4, p1, Li0/j$c;->b:Ljava/lang/String;

    const/4 v5, 0x0

    iget v6, p1, Li0/j$c;->a:I

    invoke-direct {v3, v4, v5, v6}, Landroid/app/ActivityManager$TaskDescription;-><init>(Ljava/lang/String;Landroid/graphics/Bitmap;I)V

    invoke-virtual {v2, v3}, Landroid/app/Activity;->setTaskDescription(Landroid/app/ActivityManager$TaskDescription;)V

    :cond_0
    if-lt v0, v1, :cond_1

    new-instance v0, Landroid/app/ActivityManager$TaskDescription;

    iget-object v1, p1, Li0/j$c;->b:Ljava/lang/String;

    const/4 v2, 0x0

    iget p1, p1, Li0/j$c;->a:I

    invoke-direct {v0, v1, v2, p1}, Landroid/app/ActivityManager$TaskDescription;-><init>(Ljava/lang/String;II)V

    iget-object p1, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {p1, v0}, Landroid/app/Activity;->setTaskDescription(Landroid/app/ActivityManager$TaskDescription;)V

    :cond_1
    return-void
.end method

.method private y()V
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    new-instance v1, Lio/flutter/plugin/platform/h$b;

    invoke-direct {v1, p0, v0}, Lio/flutter/plugin/platform/h$b;-><init>(Lio/flutter/plugin/platform/h;Landroid/view/View;)V

    invoke-virtual {v0, v1}, Landroid/view/View;->setOnSystemUiVisibilityChangeListener(Landroid/view/View$OnSystemUiVisibilityChangeListener;)V

    return-void
.end method

.method private z(Li0/j$k;)V
    .locals 1

    sget-object v0, Li0/j$k;->e:Li0/j$k;

    if-ne p1, v0, :cond_0

    const/16 p1, 0x706

    goto :goto_0

    :cond_0
    sget-object v0, Li0/j$k;->f:Li0/j$k;

    if-ne p1, v0, :cond_1

    const/16 p1, 0xf06

    goto :goto_0

    :cond_1
    sget-object v0, Li0/j$k;->g:Li0/j$k;

    if-ne p1, v0, :cond_2

    const/16 p1, 0x1706

    goto :goto_0

    :cond_2
    sget-object v0, Li0/j$k;->h:Li0/j$k;

    if-ne p1, v0, :cond_3

    sget p1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v0, 0x1d

    if-lt p1, v0, :cond_3

    const/16 p1, 0x700

    :goto_0
    iput p1, p0, Lio/flutter/plugin/platform/h;->e:I

    invoke-virtual {p0}, Lio/flutter/plugin/platform/h;->E()V

    :cond_3
    return-void
.end method


# virtual methods
.method public E()V
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    iget v1, p0, Lio/flutter/plugin/platform/h;->e:I

    invoke-virtual {v0, v1}, Landroid/view/View;->setSystemUiVisibility(I)V

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->d:Li0/j$j;

    if-eqz v0, :cond_0

    invoke-direct {p0, v0}, Lio/flutter/plugin/platform/h;->C(Li0/j$j;)V

    :cond_0
    return-void
.end method

.method F(Li0/j$g;)V
    .locals 3

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->a:Landroid/app/Activity;

    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Window;->getDecorView()Landroid/view/View;

    move-result-object v0

    sget-object v1, Lio/flutter/plugin/platform/h$c;->a:[I

    invoke-virtual {p1}, Ljava/lang/Enum;->ordinal()I

    move-result p1

    aget p1, v1, p1

    const/4 v1, 0x1

    if-eq p1, v1, :cond_2

    const/4 v2, 0x2

    if-eq p1, v2, :cond_1

    const/4 v1, 0x3

    if-eq p1, v1, :cond_1

    const/4 v1, 0x4

    if-eq p1, v1, :cond_0

    const/4 v2, 0x5

    if-eq p1, v2, :cond_1

    goto :goto_1

    :cond_0
    sget p1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x17

    if-lt p1, v1, :cond_3

    const/4 p1, 0x6

    goto :goto_0

    :cond_1
    invoke-virtual {v0, v1}, Landroid/view/View;->performHapticFeedback(I)Z

    goto :goto_1

    :cond_2
    const/4 p1, 0x0

    :goto_0
    invoke-virtual {v0, p1}, Landroid/view/View;->performHapticFeedback(I)Z

    :cond_3
    :goto_1
    return-void
.end method

.method public q()V
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/platform/h;->b:Li0/j;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Li0/j;->l(Li0/j$h;)V

    return-void
.end method
