.class public Lio/flutter/embedding/android/s;
.super Landroid/widget/FrameLayout;
.source "SourceFile"

# interfaces
.implements Ll0/b$c;
.implements Lio/flutter/embedding/android/a0$e;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/embedding/android/s$g;,
        Lio/flutter/embedding/android/s$f;
    }
.end annotation


# instance fields
.field private a:Lio/flutter/embedding/android/l;

.field private b:Lio/flutter/embedding/android/m;

.field private c:Lio/flutter/embedding/android/k;

.field d:Lio/flutter/embedding/engine/renderer/b;

.field private e:Lio/flutter/embedding/engine/renderer/b;

.field private final f:Ljava/util/Set;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Set<",
            "Lio/flutter/embedding/engine/renderer/a;",
            ">;"
        }
    .end annotation
.end field

.field private g:Z

.field private h:Lio/flutter/embedding/engine/a;

.field private final i:Ljava/util/Set;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Set<",
            "Lio/flutter/embedding/android/s$f;",
            ">;"
        }
    .end annotation
.end field

.field private j:Ll0/b;

.field private k:Lio/flutter/plugin/editing/m;

.field private l:Lio/flutter/plugin/editing/f;

.field private m:Lk0/c;

.field private n:Lio/flutter/embedding/android/a0;

.field private o:Lio/flutter/embedding/android/c;

.field private p:Lio/flutter/view/h;

.field private q:Landroid/view/textservice/TextServicesManager;

.field private r:Lio/flutter/embedding/android/f0;

.field private final s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

.field private final t:Lio/flutter/view/h$k;

.field private final u:Landroid/database/ContentObserver;

.field private final v:Lio/flutter/embedding/engine/renderer/a;

.field private final w:Landroidx/core/util/a;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Landroidx/core/util/a<",
            "Landroidx/window/layout/WindowLayoutInfo;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method private constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;Lio/flutter/embedding/android/l;)V
    .locals 1

    invoke-direct {p0, p1, p2}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    new-instance p1, Ljava/util/HashSet;

    invoke-direct {p1}, Ljava/util/HashSet;-><init>()V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->f:Ljava/util/Set;

    new-instance p1, Ljava/util/HashSet;

    invoke-direct {p1}, Ljava/util/HashSet;-><init>()V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->i:Ljava/util/Set;

    new-instance p1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    invoke-direct {p1}, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;-><init>()V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    new-instance p1, Lio/flutter/embedding/android/s$a;

    invoke-direct {p1, p0}, Lio/flutter/embedding/android/s$a;-><init>(Lio/flutter/embedding/android/s;)V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->t:Lio/flutter/view/h$k;

    new-instance p1, Lio/flutter/embedding/android/s$b;

    new-instance p2, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-direct {p2, v0}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    invoke-direct {p1, p0, p2}, Lio/flutter/embedding/android/s$b;-><init>(Lio/flutter/embedding/android/s;Landroid/os/Handler;)V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->u:Landroid/database/ContentObserver;

    new-instance p1, Lio/flutter/embedding/android/s$c;

    invoke-direct {p1, p0}, Lio/flutter/embedding/android/s$c;-><init>(Lio/flutter/embedding/android/s;)V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->v:Lio/flutter/embedding/engine/renderer/a;

    new-instance p1, Lio/flutter/embedding/android/s$d;

    invoke-direct {p1, p0}, Lio/flutter/embedding/android/s$d;-><init>(Lio/flutter/embedding/android/s;)V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->w:Landroidx/core/util/a;

    iput-object p3, p0, Lio/flutter/embedding/android/s;->a:Lio/flutter/embedding/android/l;

    iput-object p3, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->u()V

    return-void
.end method

.method private constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;Lio/flutter/embedding/android/m;)V
    .locals 1

    invoke-direct {p0, p1, p2}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    new-instance p1, Ljava/util/HashSet;

    invoke-direct {p1}, Ljava/util/HashSet;-><init>()V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->f:Ljava/util/Set;

    new-instance p1, Ljava/util/HashSet;

    invoke-direct {p1}, Ljava/util/HashSet;-><init>()V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->i:Ljava/util/Set;

    new-instance p1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    invoke-direct {p1}, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;-><init>()V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    new-instance p1, Lio/flutter/embedding/android/s$a;

    invoke-direct {p1, p0}, Lio/flutter/embedding/android/s$a;-><init>(Lio/flutter/embedding/android/s;)V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->t:Lio/flutter/view/h$k;

    new-instance p1, Lio/flutter/embedding/android/s$b;

    new-instance p2, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-direct {p2, v0}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    invoke-direct {p1, p0, p2}, Lio/flutter/embedding/android/s$b;-><init>(Lio/flutter/embedding/android/s;Landroid/os/Handler;)V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->u:Landroid/database/ContentObserver;

    new-instance p1, Lio/flutter/embedding/android/s$c;

    invoke-direct {p1, p0}, Lio/flutter/embedding/android/s$c;-><init>(Lio/flutter/embedding/android/s;)V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->v:Lio/flutter/embedding/engine/renderer/a;

    new-instance p1, Lio/flutter/embedding/android/s$d;

    invoke-direct {p1, p0}, Lio/flutter/embedding/android/s$d;-><init>(Lio/flutter/embedding/android/s;)V

    iput-object p1, p0, Lio/flutter/embedding/android/s;->w:Landroidx/core/util/a;

    iput-object p3, p0, Lio/flutter/embedding/android/s;->b:Lio/flutter/embedding/android/m;

    iput-object p3, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->u()V

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Lio/flutter/embedding/android/l;)V
    .locals 1

    const/4 v0, 0x0

    invoke-direct {p0, p1, v0, p2}, Lio/flutter/embedding/android/s;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;Lio/flutter/embedding/android/l;)V

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Lio/flutter/embedding/android/m;)V
    .locals 1

    const/4 v0, 0x0

    invoke-direct {p0, p1, v0, p2}, Lio/flutter/embedding/android/s;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;Lio/flutter/embedding/android/m;)V

    return-void
.end method

.method private C()V
    .locals 2

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->v()Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "FlutterView"

    const-string v1, "Tried to send viewport metrics from Android to Flutter but this FlutterView was not attached to a FlutterEngine."

    invoke-static {v0, v1}, Lw/b;->g(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_0
    iget-object v0, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    invoke-virtual {p0}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v1

    iget v1, v1, Landroid/util/DisplayMetrics;->density:F

    iput v1, v0, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->a:F

    iget-object v0, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-static {v1}, Landroid/view/ViewConfiguration;->get(Landroid/content/Context;)Landroid/view/ViewConfiguration;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/ViewConfiguration;->getScaledTouchSlop()I

    move-result v1

    iput v1, v0, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->p:I

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    invoke-virtual {v0, v1}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->x(Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;)V

    return-void
.end method

.method public static synthetic d(Landroid/view/textservice/SpellCheckerInfo;)Z
    .locals 0

    invoke-static {p0}, Lio/flutter/embedding/android/s;->w(Landroid/view/textservice/SpellCheckerInfo;)Z

    move-result p0

    return p0
.end method

.method static synthetic e(Lio/flutter/embedding/android/s;ZZ)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lio/flutter/embedding/android/s;->z(ZZ)V

    return-void
.end method

.method static synthetic f(Lio/flutter/embedding/android/s;)Lio/flutter/embedding/engine/a;
    .locals 0

    iget-object p0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    return-object p0
.end method

.method static synthetic g(Lio/flutter/embedding/android/s;Z)Z
    .locals 0

    iput-boolean p1, p0, Lio/flutter/embedding/android/s;->g:Z

    return p1
.end method

.method static synthetic h(Lio/flutter/embedding/android/s;)Ljava/util/Set;
    .locals 0

    iget-object p0, p0, Lio/flutter/embedding/android/s;->f:Ljava/util/Set;

    return-object p0
.end method

.method static synthetic i(Lio/flutter/embedding/android/s;)Lio/flutter/embedding/android/k;
    .locals 0

    iget-object p0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    return-object p0
.end method

.method static synthetic j(Lio/flutter/embedding/android/s;)V
    .locals 0

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->x()V

    return-void
.end method

.method private o()Lio/flutter/embedding/android/s$g;
    .locals 3

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v1

    iget v1, v1, Landroid/content/res/Configuration;->orientation:I

    const-string v2, "window"

    invoke-virtual {v0, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/WindowManager;

    invoke-interface {v0}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/Display;->getRotation()I

    move-result v0

    const/4 v2, 0x2

    if-ne v1, v2, :cond_4

    const/4 v1, 0x1

    if-ne v0, v1, :cond_0

    sget-object v0, Lio/flutter/embedding/android/s$g;->f:Lio/flutter/embedding/android/s$g;

    return-object v0

    :cond_0
    const/4 v1, 0x3

    if-ne v0, v1, :cond_2

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x17

    if-lt v0, v1, :cond_1

    sget-object v0, Lio/flutter/embedding/android/s$g;->e:Lio/flutter/embedding/android/s$g;

    goto :goto_0

    :cond_1
    sget-object v0, Lio/flutter/embedding/android/s$g;->f:Lio/flutter/embedding/android/s$g;

    :goto_0
    return-object v0

    :cond_2
    if-eqz v0, :cond_3

    if-ne v0, v2, :cond_4

    :cond_3
    sget-object v0, Lio/flutter/embedding/android/s$g;->g:Lio/flutter/embedding/android/s$g;

    return-object v0

    :cond_4
    sget-object v0, Lio/flutter/embedding/android/s$g;->d:Lio/flutter/embedding/android/s$g;

    return-object v0
.end method

.method private t(Landroid/view/WindowInsets;)I
    .locals 7
    .annotation build Landroid/annotation/TargetApi;
        value = 0x14
    .end annotation

    invoke-virtual {p0}, Landroid/view/View;->getRootView()Landroid/view/View;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/View;->getHeight()I

    move-result v0

    invoke-virtual {p1}, Landroid/view/WindowInsets;->getSystemWindowInsetBottom()I

    move-result v1

    int-to-double v1, v1

    int-to-double v3, v0

    const-wide v5, 0x3fc70a3d70a3d70aL    # 0.18

    mul-double v3, v3, v5

    cmpg-double v0, v1, v3

    if-gez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    invoke-virtual {p1}, Landroid/view/WindowInsets;->getSystemWindowInsetBottom()I

    move-result p1

    return p1
.end method

.method private u()V
    .locals 3

    const-string v0, "FlutterView"

    const-string v1, "Initializing FlutterView"

    invoke-static {v0, v1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v1, p0, Lio/flutter/embedding/android/s;->a:Lio/flutter/embedding/android/l;

    if-eqz v1, :cond_0

    const-string v1, "Internally using a FlutterSurfaceView."

    invoke-static {v0, v1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->a:Lio/flutter/embedding/android/l;

    :goto_0
    invoke-virtual {p0, v0}, Landroid/view/ViewGroup;->addView(Landroid/view/View;)V

    goto :goto_1

    :cond_0
    iget-object v1, p0, Lio/flutter/embedding/android/s;->b:Lio/flutter/embedding/android/m;

    if-eqz v1, :cond_1

    const-string v1, "Internally using a FlutterTextureView."

    invoke-static {v0, v1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->b:Lio/flutter/embedding/android/m;

    goto :goto_0

    :cond_1
    const-string v1, "Internally using a FlutterImageView."

    invoke-static {v0, v1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    goto :goto_0

    :goto_1
    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Landroid/view/View;->setFocusable(Z)V

    invoke-virtual {p0, v0}, Landroid/view/View;->setFocusableInTouchMode(Z)V

    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1a

    if-lt v1, v2, :cond_2

    invoke-virtual {p0, v0}, Landroid/widget/FrameLayout;->setImportantForAutofill(I)V

    :cond_2
    return-void
.end method

.method private static synthetic w(Landroid/view/textservice/SpellCheckerInfo;)Z
    .locals 1

    invoke-virtual {p0}, Landroid/view/textservice/SpellCheckerInfo;->getPackageName()Ljava/lang/String;

    move-result-object p0

    const-string v0, "com.google.android.inputmethod.latin"

    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    return p0
.end method

.method private x()V
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lio/flutter/embedding/android/k;->g()V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    invoke-virtual {p0, v0}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V

    const/4 v0, 0x0

    iput-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    :cond_0
    return-void
.end method

.method private z(ZZ)V
    .locals 2

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v0

    invoke-virtual {v0}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->o()Z

    move-result v0

    const/4 v1, 0x0

    if-nez v0, :cond_0

    if-nez p1, :cond_0

    if-nez p2, :cond_0

    const/4 v1, 0x1

    :cond_0
    invoke-virtual {p0, v1}, Landroid/view/View;->setWillNotDraw(Z)V

    return-void
.end method


# virtual methods
.method public A(Ljava/lang/Runnable;)V
    .locals 2

    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    const-string v1, "FlutterView"

    if-nez v0, :cond_0

    const-string p1, "Tried to revert the image view, but no image view is used."

    invoke-static {v1, p1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_0
    iget-object v0, p0, Lio/flutter/embedding/android/s;->e:Lio/flutter/embedding/engine/renderer/b;

    if-nez v0, :cond_1

    const-string p1, "Tried to revert the image view, but no previous surface was used."

    invoke-static {v1, p1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_1
    iput-object v0, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    const/4 v0, 0x0

    iput-object v0, p0, Lio/flutter/embedding/android/s;->e:Lio/flutter/embedding/engine/renderer/b;

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    if-eqz v1, :cond_3

    if-nez v0, :cond_2

    goto :goto_0

    :cond_2
    iget-object v1, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    invoke-interface {v1}, Lio/flutter/embedding/engine/renderer/b;->b()V

    new-instance v1, Lio/flutter/embedding/android/s$e;

    invoke-direct {v1, p0, v0, p1}, Lio/flutter/embedding/android/s$e;-><init>(Lio/flutter/embedding/android/s;Lio/flutter/embedding/engine/renderer/FlutterRenderer;Ljava/lang/Runnable;)V

    invoke-virtual {v0, v1}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->j(Lio/flutter/embedding/engine/renderer/a;)V

    return-void

    :cond_3
    :goto_0
    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    invoke-virtual {v0}, Lio/flutter/embedding/android/k;->a()V

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->x()V

    invoke-interface {p1}, Ljava/lang/Runnable;->run()V

    return-void
.end method

.method B()V
    .locals 6

    invoke-virtual {p0}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v0

    iget v0, v0, Landroid/content/res/Configuration;->uiMode:I

    and-int/lit8 v0, v0, 0x30

    const/4 v1, 0x0

    const/4 v2, 0x1

    const/16 v3, 0x20

    if-ne v0, v3, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    if-eqz v0, :cond_1

    sget-object v0, Li0/o$c;->f:Li0/o$c;

    goto :goto_1

    :cond_1
    sget-object v0, Li0/o$c;->e:Li0/o$c;

    :goto_1
    iget-object v3, p0, Lio/flutter/embedding/android/s;->q:Landroid/view/textservice/TextServicesManager;

    if-eqz v3, :cond_3

    sget v4, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v5, 0x1f

    if-lt v4, v5, :cond_2

    invoke-static {v3}, Lio/flutter/embedding/android/o;->a(Landroid/view/textservice/TextServicesManager;)Ljava/util/List;

    move-result-object v3

    invoke-static {v3}, Lio/flutter/embedding/android/p;->a(Ljava/util/List;)Ljava/util/stream/Stream;

    move-result-object v3

    new-instance v4, Lio/flutter/embedding/android/r;

    invoke-direct {v4}, Lio/flutter/embedding/android/r;-><init>()V

    invoke-interface {v3, v4}, Ljava/util/stream/Stream;->anyMatch(Ljava/util/function/Predicate;)Z

    move-result v3

    iget-object v4, p0, Lio/flutter/embedding/android/s;->q:Landroid/view/textservice/TextServicesManager;

    invoke-static {v4}, Lio/flutter/embedding/android/q;->a(Landroid/view/textservice/TextServicesManager;)Z

    move-result v4

    if-eqz v4, :cond_3

    if-eqz v3, :cond_3

    :cond_2
    const/4 v3, 0x1

    goto :goto_2

    :cond_3
    const/4 v3, 0x0

    :goto_2
    iget-object v4, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v4}, Lio/flutter/embedding/engine/a;->u()Li0/o;

    move-result-object v4

    invoke-virtual {v4}, Li0/o;->d()Li0/o$b;

    move-result-object v4

    invoke-virtual {p0}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v5

    iget v5, v5, Landroid/content/res/Configuration;->fontScale:F

    invoke-virtual {v4, v5}, Li0/o$b;->f(F)Li0/o$b;

    move-result-object v4

    invoke-virtual {p0}, Landroid/view/View;->getResources()Landroid/content/res/Resources;

    move-result-object v5

    invoke-virtual {v5}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v5

    invoke-virtual {v4, v5}, Li0/o$b;->c(Landroid/util/DisplayMetrics;)Li0/o$b;

    move-result-object v4

    invoke-virtual {v4, v3}, Li0/o$b;->d(Z)Li0/o$b;

    move-result-object v3

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-virtual {v4}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v4

    const-string v5, "show_password"

    invoke-static {v4, v5, v2}, Landroid/provider/Settings$System;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result v4

    if-ne v4, v2, :cond_4

    const/4 v1, 0x1

    :cond_4
    invoke-virtual {v3, v1}, Li0/o$b;->b(Z)Li0/o$b;

    move-result-object v1

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-static {v2}, Landroid/text/format/DateFormat;->is24HourFormat(Landroid/content/Context;)Z

    move-result v2

    invoke-virtual {v1, v2}, Li0/o$b;->g(Z)Li0/o$b;

    move-result-object v1

    invoke-virtual {v1, v0}, Li0/o$b;->e(Li0/o$c;)Li0/o$b;

    move-result-object v0

    invoke-virtual {v0}, Li0/o$b;->a()V

    return-void
.end method

.method public a(Landroid/view/KeyEvent;)V
    .locals 1

    invoke-virtual {p0}, Landroid/view/View;->getRootView()Landroid/view/View;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/view/View;->dispatchKeyEvent(Landroid/view/KeyEvent;)Z

    return-void
.end method

.method public autofill(Landroid/util/SparseArray;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/util/SparseArray<",
            "Landroid/view/autofill/AutofillValue;",
            ">;)V"
        }
    .end annotation

    iget-object v0, p0, Lio/flutter/embedding/android/s;->k:Lio/flutter/plugin/editing/m;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/editing/m;->j(Landroid/util/SparseArray;)V

    return-void
.end method

.method public b(I)Landroid/view/PointerIcon;
    .locals 1
    .annotation build Landroid/annotation/TargetApi;
        value = 0x18
    .end annotation

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0, p1}, Landroid/view/PointerIcon;->getSystemIcon(Landroid/content/Context;I)Landroid/view/PointerIcon;

    move-result-object p1

    return-object p1
.end method

.method public c(Landroid/view/KeyEvent;)Z
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->k:Lio/flutter/plugin/editing/m;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/editing/m;->r(Landroid/view/KeyEvent;)Z

    move-result p1

    return p1
.end method

.method public checkInputConnectionProxy(Landroid/view/View;)Z
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v0

    invoke-virtual {v0, p1}, Lio/flutter/plugin/platform/w;->G(Landroid/view/View;)Z

    move-result p1

    goto :goto_0

    :cond_0
    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->checkInputConnectionProxy(Landroid/view/View;)Z

    move-result p1

    :goto_0
    return p1
.end method

.method public dispatchKeyEvent(Landroid/view/KeyEvent;)Z
    .locals 2

    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I

    move-result v0

    const/4 v1, 0x1

    if-nez v0, :cond_0

    invoke-virtual {p1}, Landroid/view/KeyEvent;->getRepeatCount()I

    move-result v0

    if-nez v0, :cond_0

    invoke-virtual {p0}, Landroid/view/View;->getKeyDispatcherState()Landroid/view/KeyEvent$DispatcherState;

    move-result-object v0

    invoke-virtual {v0, p1, p0}, Landroid/view/KeyEvent$DispatcherState;->startTracking(Landroid/view/KeyEvent;Ljava/lang/Object;)V

    goto :goto_0

    :cond_0
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I

    move-result v0

    if-ne v0, v1, :cond_1

    invoke-virtual {p0}, Landroid/view/View;->getKeyDispatcherState()Landroid/view/KeyEvent$DispatcherState;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/view/KeyEvent$DispatcherState;->handleUpEvent(Landroid/view/KeyEvent;)V

    :cond_1
    :goto_0
    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->v()Z

    move-result v0

    if-eqz v0, :cond_2

    iget-object v0, p0, Lio/flutter/embedding/android/s;->n:Lio/flutter/embedding/android/a0;

    invoke-virtual {v0, p1}, Lio/flutter/embedding/android/a0;->b(Landroid/view/KeyEvent;)Z

    move-result v0

    if-nez v0, :cond_4

    :cond_2
    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->dispatchKeyEvent(Landroid/view/KeyEvent;)Z

    move-result p1

    if-eqz p1, :cond_3

    goto :goto_1

    :cond_3
    const/4 v1, 0x0

    :cond_4
    :goto_1
    return v1
.end method

.method protected fitSystemWindows(Landroid/graphics/Rect;)Z
    .locals 0

    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->fitSystemWindows(Landroid/graphics/Rect;)Z

    move-result p1

    return p1
.end method

.method public getAccessibilityNodeProvider()Landroid/view/accessibility/AccessibilityNodeProvider;
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lio/flutter/view/h;->C()Z

    move-result v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    return-object v0

    :cond_0
    const/4 v0, 0x0

    return-object v0
.end method

.method public getAttachedFlutterEngine()Lio/flutter/embedding/engine/a;
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    return-object v0
.end method

.method public getBinaryMessenger()Lj0/c;
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->j()Lx/a;

    move-result-object v0

    return-object v0
.end method

.method public getCurrentImageSurface()Lio/flutter/embedding/android/k;
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    return-object v0
.end method

.method public k()Z
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lio/flutter/embedding/android/k;->e()Z

    move-result v0

    return v0

    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method public l(Lio/flutter/embedding/engine/renderer/a;)V
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->f:Ljava/util/Set;

    invoke-interface {v0, p1}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    return-void
.end method

.method public m(Lio/flutter/embedding/android/k;)V
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v0

    invoke-virtual {p1, v0}, Lio/flutter/embedding/android/k;->c(Lio/flutter/embedding/engine/renderer/FlutterRenderer;)V

    :cond_0
    return-void
.end method

.method public n(Lio/flutter/embedding/engine/a;)V
    .locals 9

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Attaching to a FlutterEngine: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "FlutterView"

    invoke-static {v1, v0}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->v()Z

    move-result v0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    if-ne p1, v0, :cond_0

    const-string p1, "Already attached to this engine. Doing nothing."

    invoke-static {v1, p1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_0
    const-string v0, "Currently attached to a different engine. Detaching and then attaching to new engine."

    invoke-static {v1, v0}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->s()V

    :cond_1
    iput-object p1, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {p1}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v0

    invoke-virtual {v0}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->n()Z

    move-result v2

    iput-boolean v2, p0, Lio/flutter/embedding/android/s;->g:Z

    iget-object v2, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    invoke-interface {v2, v0}, Lio/flutter/embedding/engine/renderer/b;->c(Lio/flutter/embedding/engine/renderer/FlutterRenderer;)V

    iget-object v2, p0, Lio/flutter/embedding/android/s;->v:Lio/flutter/embedding/engine/renderer/a;

    invoke-virtual {v0, v2}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->j(Lio/flutter/embedding/engine/renderer/a;)V

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x18

    if-lt v0, v2, :cond_2

    new-instance v0, Ll0/b;

    iget-object v2, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v2}, Lio/flutter/embedding/engine/a;->m()Li0/h;

    move-result-object v2

    invoke-direct {v0, p0, v2}, Ll0/b;-><init>(Ll0/b$c;Li0/h;)V

    iput-object v0, p0, Lio/flutter/embedding/android/s;->j:Ll0/b;

    :cond_2
    new-instance v0, Lio/flutter/plugin/editing/m;

    iget-object v2, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v2}, Lio/flutter/embedding/engine/a;->x()Li0/r;

    move-result-object v2

    iget-object v3, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v3}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v3

    invoke-direct {v0, p0, v2, v3}, Lio/flutter/plugin/editing/m;-><init>(Landroid/view/View;Li0/r;Lio/flutter/plugin/platform/w;)V

    iput-object v0, p0, Lio/flutter/embedding/android/s;->k:Lio/flutter/plugin/editing/m;

    :try_start_0
    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string v2, "textservices"

    invoke-virtual {v0, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/textservice/TextServicesManager;

    iput-object v0, p0, Lio/flutter/embedding/android/s;->q:Landroid/view/textservice/TextServicesManager;

    new-instance v2, Lio/flutter/plugin/editing/f;

    iget-object v3, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v3}, Lio/flutter/embedding/engine/a;->v()Li0/p;

    move-result-object v3

    invoke-direct {v2, v0, v3}, Lio/flutter/plugin/editing/f;-><init>(Landroid/view/textservice/TextServicesManager;Li0/p;)V

    iput-object v2, p0, Lio/flutter/embedding/android/s;->l:Lio/flutter/plugin/editing/f;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    const-string v0, "TextServicesManager not supported by device, spell check disabled."

    invoke-static {v1, v0}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    :goto_0
    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->l()Lk0/c;

    move-result-object v0

    iput-object v0, p0, Lio/flutter/embedding/android/s;->m:Lk0/c;

    new-instance v0, Lio/flutter/embedding/android/a0;

    invoke-direct {v0, p0}, Lio/flutter/embedding/android/a0;-><init>(Lio/flutter/embedding/android/a0$e;)V

    iput-object v0, p0, Lio/flutter/embedding/android/s;->n:Lio/flutter/embedding/android/a0;

    new-instance v0, Lio/flutter/embedding/android/c;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v1}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v1

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lio/flutter/embedding/android/c;-><init>(Lio/flutter/embedding/engine/renderer/FlutterRenderer;Z)V

    iput-object v0, p0, Lio/flutter/embedding/android/s;->o:Lio/flutter/embedding/android/c;

    new-instance v0, Lio/flutter/view/h;

    invoke-virtual {p1}, Lio/flutter/embedding/engine/a;->h()Li0/a;

    move-result-object v5

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v1

    const-string v3, "accessibility"

    invoke-virtual {v1, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    move-object v6, v1

    check-cast v6, Landroid/view/accessibility/AccessibilityManager;

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v7

    iget-object v1, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v1}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v8

    move-object v3, v0

    move-object v4, p0

    invoke-direct/range {v3 .. v8}, Lio/flutter/view/h;-><init>(Landroid/view/View;Li0/a;Landroid/view/accessibility/AccessibilityManager;Landroid/content/ContentResolver;Lio/flutter/plugin/platform/q;)V

    iput-object v0, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->t:Lio/flutter/view/h$k;

    invoke-virtual {v0, v1}, Lio/flutter/view/h;->a0(Lio/flutter/view/h$k;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    invoke-virtual {v0}, Lio/flutter/view/h;->C()Z

    move-result v0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    invoke-virtual {v1}, Lio/flutter/view/h;->E()Z

    move-result v1

    invoke-direct {p0, v0, v1}, Lio/flutter/embedding/android/s;->z(ZZ)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    invoke-virtual {v0, v1}, Lio/flutter/plugin/platform/w;->a(Lio/flutter/view/h;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v1}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v1

    invoke-virtual {v0, v1}, Lio/flutter/plugin/platform/w;->E(Lio/flutter/embedding/engine/renderer/FlutterRenderer;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->k:Lio/flutter/plugin/editing/m;

    invoke-virtual {v0}, Lio/flutter/plugin/editing/m;->q()Landroid/view/inputmethod/InputMethodManager;

    move-result-object v0

    invoke-virtual {v0, p0}, Landroid/view/inputmethod/InputMethodManager;->restartInput(Landroid/view/View;)V

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->B()V

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const-string v1, "show_password"

    invoke-static {v1}, Landroid/provider/Settings$System;->getUriFor(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    iget-object v3, p0, Lio/flutter/embedding/android/s;->u:Landroid/database/ContentObserver;

    invoke-virtual {v0, v1, v2, v3}, Landroid/content/ContentResolver;->registerContentObserver(Landroid/net/Uri;ZLandroid/database/ContentObserver;)V

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->C()V

    invoke-virtual {p1}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v0

    invoke-virtual {v0, p0}, Lio/flutter/plugin/platform/w;->F(Lio/flutter/embedding/android/s;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->i:Ljava/util/Set;

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_3

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lio/flutter/embedding/android/s$f;

    invoke-interface {v1, p1}, Lio/flutter/embedding/android/s$f;->b(Lio/flutter/embedding/engine/a;)V

    goto :goto_1

    :cond_3
    iget-boolean p1, p0, Lio/flutter/embedding/android/s;->g:Z

    if-eqz p1, :cond_4

    iget-object p1, p0, Lio/flutter/embedding/android/s;->v:Lio/flutter/embedding/engine/renderer/a;

    invoke-interface {p1}, Lio/flutter/embedding/engine/renderer/a;->f()V

    :cond_4
    return-void
.end method

.method public final onApplyWindowInsets(Landroid/view/WindowInsets;)Landroid/view/WindowInsets;
    .locals 6
    .annotation build Landroid/annotation/SuppressLint;
        value = {
            "InlinedApi",
            "NewApi"
        }
    .end annotation

    .annotation build Landroid/annotation/TargetApi;
        value = 0x14
    .end annotation

    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->onApplyWindowInsets(Landroid/view/WindowInsets;)Landroid/view/WindowInsets;

    move-result-object v0

    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x1d

    if-ne v1, v2, :cond_0

    invoke-static {p1}, Landroidx/core/view/w;->a(Landroid/view/WindowInsets;)Landroid/graphics/Insets;

    move-result-object v2

    iget-object v3, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v4, v2, Landroid/graphics/Insets;->top:I

    iput v4, v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->l:I

    iget v4, v2, Landroid/graphics/Insets;->right:I

    iput v4, v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->m:I

    iget v4, v2, Landroid/graphics/Insets;->bottom:I

    iput v4, v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->n:I

    iget v2, v2, Landroid/graphics/Insets;->left:I

    iput v2, v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->o:I

    :cond_0
    invoke-virtual {p0}, Landroid/view/View;->getWindowSystemUiVisibility()I

    move-result v2

    and-int/lit8 v2, v2, 0x4

    const/4 v3, 0x1

    const/4 v4, 0x0

    if-nez v2, :cond_1

    const/4 v2, 0x1

    goto :goto_0

    :cond_1
    const/4 v2, 0x0

    :goto_0
    invoke-virtual {p0}, Landroid/view/View;->getWindowSystemUiVisibility()I

    move-result v5

    and-int/lit8 v5, v5, 0x2

    if-nez v5, :cond_2

    goto :goto_1

    :cond_2
    const/4 v3, 0x0

    :goto_1
    const/16 v5, 0x1e

    if-lt v1, v5, :cond_5

    if-eqz v3, :cond_3

    invoke-static {}, Landroid/view/WindowInsets$Type;->navigationBars()I

    move-result v1

    or-int/2addr v4, v1

    :cond_3
    if-eqz v2, :cond_4

    invoke-static {}, Landroid/view/WindowInsets$Type;->statusBars()I

    move-result v1

    or-int/2addr v4, v1

    :cond_4
    invoke-static {p1, v4}, Landroidx/core/view/a0;->a(Landroid/view/WindowInsets;I)Landroid/graphics/Insets;

    move-result-object v1

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v1, Landroid/graphics/Insets;->top:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->d:I

    iget v3, v1, Landroid/graphics/Insets;->right:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->e:I

    iget v3, v1, Landroid/graphics/Insets;->bottom:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->f:I

    iget v1, v1, Landroid/graphics/Insets;->left:I

    iput v1, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->g:I

    invoke-static {}, Landroid/view/WindowInsets$Type;->ime()I

    move-result v1

    invoke-static {p1, v1}, Landroidx/core/view/a0;->a(Landroid/view/WindowInsets;I)Landroid/graphics/Insets;

    move-result-object v1

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v1, Landroid/graphics/Insets;->top:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->h:I

    iget v3, v1, Landroid/graphics/Insets;->right:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->i:I

    iget v3, v1, Landroid/graphics/Insets;->bottom:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->j:I

    iget v1, v1, Landroid/graphics/Insets;->left:I

    iput v1, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->k:I

    invoke-static {}, Landroid/view/WindowInsets$Type;->systemGestures()I

    move-result v1

    invoke-static {p1, v1}, Landroidx/core/view/a0;->a(Landroid/view/WindowInsets;I)Landroid/graphics/Insets;

    move-result-object v1

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v1, Landroid/graphics/Insets;->top:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->l:I

    iget v3, v1, Landroid/graphics/Insets;->right:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->m:I

    iget v3, v1, Landroid/graphics/Insets;->bottom:I

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->n:I

    iget v1, v1, Landroid/graphics/Insets;->left:I

    iput v1, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->o:I

    invoke-static {p1}, Landroidx/core/view/u;->a(Landroid/view/WindowInsets;)Landroid/view/DisplayCutout;

    move-result-object p1

    if-eqz p1, :cond_d

    invoke-static {p1}, Lio/flutter/embedding/android/n;->a(Landroid/view/DisplayCutout;)Landroid/graphics/Insets;

    move-result-object v1

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->d:I

    iget v4, v1, Landroid/graphics/Insets;->top:I

    invoke-static {v3, v4}, Ljava/lang/Math;->max(II)I

    move-result v3

    invoke-virtual {p1}, Landroid/view/DisplayCutout;->getSafeInsetTop()I

    move-result v4

    invoke-static {v3, v4}, Ljava/lang/Math;->max(II)I

    move-result v3

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->d:I

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->e:I

    iget v4, v1, Landroid/graphics/Insets;->right:I

    invoke-static {v3, v4}, Ljava/lang/Math;->max(II)I

    move-result v3

    invoke-virtual {p1}, Landroid/view/DisplayCutout;->getSafeInsetRight()I

    move-result v4

    invoke-static {v3, v4}, Ljava/lang/Math;->max(II)I

    move-result v3

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->e:I

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->f:I

    iget v4, v1, Landroid/graphics/Insets;->bottom:I

    invoke-static {v3, v4}, Ljava/lang/Math;->max(II)I

    move-result v3

    invoke-virtual {p1}, Landroid/view/DisplayCutout;->getSafeInsetBottom()I

    move-result v4

    invoke-static {v3, v4}, Ljava/lang/Math;->max(II)I

    move-result v3

    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->f:I

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->g:I

    iget v1, v1, Landroid/graphics/Insets;->left:I

    invoke-static {v3, v1}, Ljava/lang/Math;->max(II)I

    move-result v1

    invoke-virtual {p1}, Landroid/view/DisplayCutout;->getSafeInsetLeft()I

    move-result p1

    invoke-static {v1, p1}, Ljava/lang/Math;->max(II)I

    move-result p1

    iput p1, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->g:I

    goto :goto_8

    :cond_5
    sget-object v1, Lio/flutter/embedding/android/s$g;->d:Lio/flutter/embedding/android/s$g;

    if-nez v3, :cond_6

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->o()Lio/flutter/embedding/android/s$g;

    move-result-object v1

    :cond_6
    iget-object v5, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    if-eqz v2, :cond_7

    invoke-virtual {p1}, Landroid/view/WindowInsets;->getSystemWindowInsetTop()I

    move-result v2

    goto :goto_2

    :cond_7
    const/4 v2, 0x0

    :goto_2
    iput v2, v5, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->d:I

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    sget-object v5, Lio/flutter/embedding/android/s$g;->f:Lio/flutter/embedding/android/s$g;

    if-eq v1, v5, :cond_9

    sget-object v5, Lio/flutter/embedding/android/s$g;->g:Lio/flutter/embedding/android/s$g;

    if-ne v1, v5, :cond_8

    goto :goto_3

    :cond_8
    invoke-virtual {p1}, Landroid/view/WindowInsets;->getSystemWindowInsetRight()I

    move-result v5

    goto :goto_4

    :cond_9
    :goto_3
    const/4 v5, 0x0

    :goto_4
    iput v5, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->e:I

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    if-eqz v3, :cond_a

    invoke-direct {p0, p1}, Lio/flutter/embedding/android/s;->t(Landroid/view/WindowInsets;)I

    move-result v3

    if-nez v3, :cond_a

    invoke-virtual {p1}, Landroid/view/WindowInsets;->getSystemWindowInsetBottom()I

    move-result v3

    goto :goto_5

    :cond_a
    const/4 v3, 0x0

    :goto_5
    iput v3, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->f:I

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    sget-object v3, Lio/flutter/embedding/android/s$g;->e:Lio/flutter/embedding/android/s$g;

    if-eq v1, v3, :cond_c

    sget-object v3, Lio/flutter/embedding/android/s$g;->g:Lio/flutter/embedding/android/s$g;

    if-ne v1, v3, :cond_b

    goto :goto_6

    :cond_b
    invoke-virtual {p1}, Landroid/view/WindowInsets;->getSystemWindowInsetLeft()I

    move-result v1

    goto :goto_7

    :cond_c
    :goto_6
    const/4 v1, 0x0

    :goto_7
    iput v1, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->g:I

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iput v4, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->h:I

    iput v4, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->i:I

    invoke-direct {p0, p1}, Lio/flutter/embedding/android/s;->t(Landroid/view/WindowInsets;)I

    move-result p1

    iput p1, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->j:I

    iget-object p1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iput v4, p1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->k:I

    :cond_d
    :goto_8
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Updating window insets (onApplyWindowInsets()):\nStatus bar insets: Top: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v1, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->d:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, ", Left: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v2, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v2, v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->g:I

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, ", Right: "

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v3, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->e:I

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, "\nKeyboard insets: Bottom: "

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v3, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v3, v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->j:I

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v1, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->k:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v1, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->i:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, "System Gesture Insets - Left: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v1, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->o:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, ", Top: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v1, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->l:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v1, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->m:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, ", Bottom: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iget v1, v1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->j:I

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v1, "FlutterView"

    invoke-static {v1, p1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->C()V

    return-object v0
.end method

.method protected onAttachedToWindow()V
    .locals 4

    invoke-super {p0}, Landroid/widget/FrameLayout;->onAttachedToWindow()V

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->r()Lio/flutter/embedding/android/f0;

    move-result-object v0

    iput-object v0, p0, Lio/flutter/embedding/android/s;->r:Lio/flutter/embedding/android/f0;

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lp0/i;->f(Landroid/content/Context;)Landroid/app/Activity;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->r:Lio/flutter/embedding/android/f0;

    if-eqz v1, :cond_0

    if-eqz v0, :cond_0

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-static {v2}, Landroidx/core/content/b;->b(Landroid/content/Context;)Ljava/util/concurrent/Executor;

    move-result-object v2

    iget-object v3, p0, Lio/flutter/embedding/android/s;->w:Landroidx/core/util/a;

    invoke-virtual {v1, v0, v2, v3}, Lio/flutter/embedding/android/f0;->a(Landroid/app/Activity;Ljava/util/concurrent/Executor;Landroidx/core/util/a;)V

    :cond_0
    return-void
.end method

.method protected onConfigurationChanged(Landroid/content/res/Configuration;)V
    .locals 2

    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->onConfigurationChanged(Landroid/content/res/Configuration;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    if-eqz v0, :cond_0

    const-string v0, "FlutterView"

    const-string v1, "Configuration changed. Sending locales and user settings to Flutter."

    invoke-static {v0, v1}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->m:Lk0/c;

    invoke-virtual {v0, p1}, Lk0/c;->d(Landroid/content/res/Configuration;)V

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->B()V

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object p1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-static {p1, v0}, Lp0/i;->c(Landroid/content/Context;Lp0/i$a;)V

    :cond_0
    return-void
.end method

.method public onCreateInputConnection(Landroid/view/inputmethod/EditorInfo;)Landroid/view/inputmethod/InputConnection;
    .locals 2

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->v()Z

    move-result v0

    if-nez v0, :cond_0

    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->onCreateInputConnection(Landroid/view/inputmethod/EditorInfo;)Landroid/view/inputmethod/InputConnection;

    move-result-object p1

    return-object p1

    :cond_0
    iget-object v0, p0, Lio/flutter/embedding/android/s;->k:Lio/flutter/plugin/editing/m;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->n:Lio/flutter/embedding/android/a0;

    invoke-virtual {v0, p0, v1, p1}, Lio/flutter/plugin/editing/m;->o(Landroid/view/View;Lio/flutter/embedding/android/a0;Landroid/view/inputmethod/EditorInfo;)Landroid/view/inputmethod/InputConnection;

    move-result-object p1

    return-object p1
.end method

.method protected onDetachedFromWindow()V
    .locals 2

    iget-object v0, p0, Lio/flutter/embedding/android/s;->r:Lio/flutter/embedding/android/f0;

    if-eqz v0, :cond_0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->w:Landroidx/core/util/a;

    invoke-virtual {v0, v1}, Lio/flutter/embedding/android/f0;->b(Landroidx/core/util/a;)V

    :cond_0
    const/4 v0, 0x0

    iput-object v0, p0, Lio/flutter/embedding/android/s;->r:Lio/flutter/embedding/android/f0;

    invoke-super {p0}, Landroid/widget/FrameLayout;->onDetachedFromWindow()V

    return-void
.end method

.method public onGenericMotionEvent(Landroid/view/MotionEvent;)Z
    .locals 3

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->v()Z

    move-result v0

    const/4 v1, 0x1

    if-eqz v0, :cond_0

    iget-object v0, p0, Lio/flutter/embedding/android/s;->o:Lio/flutter/embedding/android/c;

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v0, p1, v2}, Lio/flutter/embedding/android/c;->j(Landroid/view/MotionEvent;Landroid/content/Context;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    if-eqz v0, :cond_1

    goto :goto_1

    :cond_1
    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->onGenericMotionEvent(Landroid/view/MotionEvent;)Z

    move-result v1

    :goto_1
    return v1
.end method

.method public onHoverEvent(Landroid/view/MotionEvent;)Z
    .locals 1

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->v()Z

    move-result v0

    if-nez v0, :cond_0

    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->onHoverEvent(Landroid/view/MotionEvent;)Z

    move-result p1

    return p1

    :cond_0
    iget-object v0, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    invoke-virtual {v0, p1}, Lio/flutter/view/h;->L(Landroid/view/MotionEvent;)Z

    move-result p1

    return p1
.end method

.method public onProvideAutofillVirtualStructure(Landroid/view/ViewStructure;I)V
    .locals 1

    invoke-super {p0, p1, p2}, Landroid/widget/FrameLayout;->onProvideAutofillVirtualStructure(Landroid/view/ViewStructure;I)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->k:Lio/flutter/plugin/editing/m;

    invoke-virtual {v0, p1, p2}, Lio/flutter/plugin/editing/m;->A(Landroid/view/ViewStructure;I)V

    return-void
.end method

.method protected onSizeChanged(IIII)V
    .locals 2

    invoke-super {p0, p1, p2, p3, p4}, Landroid/widget/FrameLayout;->onSizeChanged(IIII)V

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Size changed. Sending Flutter new viewport metrics. FlutterView was "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p3, " x "

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p4, ", it is now "

    invoke-virtual {v0, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p3

    const-string p4, "FlutterView"

    invoke-static {p4, p3}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    iget-object p3, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iput p1, p3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->b:I

    iput p2, p3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->c:I

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->C()V

    return-void
.end method

.method public onTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 1

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->v()Z

    move-result v0

    if-nez v0, :cond_0

    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->onTouchEvent(Landroid/view/MotionEvent;)Z

    move-result p1

    return p1

    :cond_0
    invoke-virtual {p0, p1}, Landroid/view/View;->requestUnbufferedDispatch(Landroid/view/MotionEvent;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->o:Lio/flutter/embedding/android/c;

    invoke-virtual {v0, p1}, Lio/flutter/embedding/android/c;->k(Landroid/view/MotionEvent;)Z

    move-result p1

    return p1
.end method

.method public p()V
    .locals 3

    iget-object v0, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    invoke-interface {v0}, Lio/flutter/embedding/engine/renderer/b;->d()V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    if-nez v0, :cond_0

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->q()Lio/flutter/embedding/android/k;

    move-result-object v0

    iput-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    invoke-virtual {p0, v0}, Landroid/view/ViewGroup;->addView(Landroid/view/View;)V

    goto :goto_0

    :cond_0
    invoke-virtual {p0}, Landroid/view/View;->getWidth()I

    move-result v1

    invoke-virtual {p0}, Landroid/view/View;->getHeight()I

    move-result v2

    invoke-virtual {v0, v1, v2}, Lio/flutter/embedding/android/k;->k(II)V

    :goto_0
    iget-object v0, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    iput-object v0, p0, Lio/flutter/embedding/android/s;->e:Lio/flutter/embedding/engine/renderer/b;

    iget-object v0, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    iput-object v0, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    if-eqz v1, :cond_1

    invoke-virtual {v1}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v1

    invoke-interface {v0, v1}, Lio/flutter/embedding/engine/renderer/b;->c(Lio/flutter/embedding/engine/renderer/FlutterRenderer;)V

    :cond_1
    return-void
.end method

.method public q()Lio/flutter/embedding/android/k;
    .locals 5

    new-instance v0, Lio/flutter/embedding/android/k;

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {p0}, Landroid/view/View;->getWidth()I

    move-result v2

    invoke-virtual {p0}, Landroid/view/View;->getHeight()I

    move-result v3

    sget-object v4, Lio/flutter/embedding/android/k$b;->d:Lio/flutter/embedding/android/k$b;

    invoke-direct {v0, v1, v2, v3, v4}, Lio/flutter/embedding/android/k;-><init>(Landroid/content/Context;IILio/flutter/embedding/android/k$b;)V

    return-object v0
.end method

.method protected r()Lio/flutter/embedding/android/f0;
    .locals 4

    :try_start_0
    new-instance v0, Lio/flutter/embedding/android/f0;

    new-instance v1, Landroidx/window/java/layout/WindowInfoTrackerCallbackAdapter;

    sget-object v2, Landroidx/window/layout/WindowInfoTracker;->Companion:Landroidx/window/layout/WindowInfoTracker$Companion;

    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-virtual {v2, v3}, Landroidx/window/layout/WindowInfoTracker$Companion;->getOrCreate(Landroid/content/Context;)Landroidx/window/layout/WindowInfoTracker;

    move-result-object v2

    invoke-direct {v1, v2}, Landroidx/window/java/layout/WindowInfoTrackerCallbackAdapter;-><init>(Landroidx/window/layout/WindowInfoTracker;)V

    invoke-direct {v0, v1}, Lio/flutter/embedding/android/f0;-><init>(Landroidx/window/java/layout/WindowInfoTrackerCallbackAdapter;)V
    :try_end_0
    .catch Ljava/lang/NoClassDefFoundError; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    :catch_0
    const/4 v0, 0x0

    return-object v0
.end method

.method public s()V
    .locals 4

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Detaching from a FlutterEngine: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "FlutterView"

    invoke-static {v1, v0}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {p0}, Lio/flutter/embedding/android/s;->v()Z

    move-result v0

    if-nez v0, :cond_0

    const-string v0, "FlutterView not attached to an engine. Not detaching."

    invoke-static {v1, v0}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_0
    iget-object v0, p0, Lio/flutter/embedding/android/s;->i:Ljava/util/Set;

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lio/flutter/embedding/android/s$f;

    invoke-interface {v1}, Lio/flutter/embedding/android/s$f;->a()V

    goto :goto_0

    :cond_1
    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->u:Landroid/database/ContentObserver;

    invoke-virtual {v0, v1}, Landroid/content/ContentResolver;->unregisterContentObserver(Landroid/database/ContentObserver;)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v0

    invoke-virtual {v0}, Lio/flutter/plugin/platform/w;->P()V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->p()Lio/flutter/plugin/platform/w;

    move-result-object v0

    invoke-virtual {v0}, Lio/flutter/plugin/platform/w;->d()V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    invoke-virtual {v0}, Lio/flutter/view/h;->S()V

    const/4 v0, 0x0

    iput-object v0, p0, Lio/flutter/embedding/android/s;->p:Lio/flutter/view/h;

    iget-object v1, p0, Lio/flutter/embedding/android/s;->k:Lio/flutter/plugin/editing/m;

    invoke-virtual {v1}, Lio/flutter/plugin/editing/m;->q()Landroid/view/inputmethod/InputMethodManager;

    move-result-object v1

    invoke-virtual {v1, p0}, Landroid/view/inputmethod/InputMethodManager;->restartInput(Landroid/view/View;)V

    iget-object v1, p0, Lio/flutter/embedding/android/s;->k:Lio/flutter/plugin/editing/m;

    invoke-virtual {v1}, Lio/flutter/plugin/editing/m;->p()V

    iget-object v1, p0, Lio/flutter/embedding/android/s;->n:Lio/flutter/embedding/android/a0;

    invoke-virtual {v1}, Lio/flutter/embedding/android/a0;->d()V

    iget-object v1, p0, Lio/flutter/embedding/android/s;->l:Lio/flutter/plugin/editing/f;

    if-eqz v1, :cond_2

    invoke-virtual {v1}, Lio/flutter/plugin/editing/f;->b()V

    :cond_2
    iget-object v1, p0, Lio/flutter/embedding/android/s;->j:Ll0/b;

    if-eqz v1, :cond_3

    invoke-virtual {v1}, Ll0/b;->c()V

    :cond_3
    iget-object v1, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    invoke-virtual {v1}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v1

    const/4 v2, 0x0

    iput-boolean v2, p0, Lio/flutter/embedding/android/s;->g:Z

    iget-object v3, p0, Lio/flutter/embedding/android/s;->v:Lio/flutter/embedding/engine/renderer/a;

    invoke-virtual {v1, v3}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->u(Lio/flutter/embedding/engine/renderer/a;)V

    invoke-virtual {v1}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->z()V

    invoke-virtual {v1, v2}, Lio/flutter/embedding/engine/renderer/FlutterRenderer;->w(Z)V

    iget-object v1, p0, Lio/flutter/embedding/android/s;->e:Lio/flutter/embedding/engine/renderer/b;

    if-eqz v1, :cond_4

    iget-object v2, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    iget-object v3, p0, Lio/flutter/embedding/android/s;->c:Lio/flutter/embedding/android/k;

    if-ne v2, v3, :cond_4

    iput-object v1, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    :cond_4
    iget-object v1, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    invoke-interface {v1}, Lio/flutter/embedding/engine/renderer/b;->a()V

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->x()V

    iput-object v0, p0, Lio/flutter/embedding/android/s;->e:Lio/flutter/embedding/engine/renderer/b;

    iput-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    return-void
.end method

.method public setVisibility(I)V
    .locals 2

    invoke-super {p0, p1}, Landroid/widget/FrameLayout;->setVisibility(I)V

    iget-object v0, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    instance-of v1, v0, Lio/flutter/embedding/android/l;

    if-eqz v1, :cond_0

    check-cast v0, Lio/flutter/embedding/android/l;

    invoke-virtual {v0, p1}, Landroid/view/View;->setVisibility(I)V

    :cond_0
    return-void
.end method

.method protected setWindowInfoListenerDisplayFeatures(Landroidx/window/layout/WindowLayoutInfo;)V
    .locals 6
    .annotation build Landroid/annotation/TargetApi;
        value = 0x1c
    .end annotation

    invoke-virtual {p1}, Landroidx/window/layout/WindowLayoutInfo;->getDisplayFeatures()Ljava/util/List;

    move-result-object p1

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    const-string v2, "FlutterView"

    if-eqz v1, :cond_4

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroidx/window/layout/DisplayFeature;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "WindowInfoTracker Display Feature reported with bounds = "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-interface {v1}, Landroidx/window/layout/DisplayFeature;->getBounds()Landroid/graphics/Rect;

    move-result-object v4

    invoke-virtual {v4}, Landroid/graphics/Rect;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v4, " and type = "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    instance-of v2, v1, Landroidx/window/layout/FoldingFeature;

    if-eqz v2, :cond_3

    move-object v2, v1

    check-cast v2, Landroidx/window/layout/FoldingFeature;

    invoke-interface {v2}, Landroidx/window/layout/FoldingFeature;->getOcclusionType()Landroidx/window/layout/FoldingFeature$OcclusionType;

    move-result-object v3

    sget-object v4, Landroidx/window/layout/FoldingFeature$OcclusionType;->FULL:Landroidx/window/layout/FoldingFeature$OcclusionType;

    if-ne v3, v4, :cond_0

    sget-object v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;->g:Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;

    goto :goto_1

    :cond_0
    sget-object v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;->f:Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;

    :goto_1
    invoke-interface {v2}, Landroidx/window/layout/FoldingFeature;->getState()Landroidx/window/layout/FoldingFeature$State;

    move-result-object v4

    sget-object v5, Landroidx/window/layout/FoldingFeature$State;->FLAT:Landroidx/window/layout/FoldingFeature$State;

    if-ne v4, v5, :cond_1

    sget-object v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;->f:Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;

    goto :goto_2

    :cond_1
    invoke-interface {v2}, Landroidx/window/layout/FoldingFeature;->getState()Landroidx/window/layout/FoldingFeature$State;

    move-result-object v2

    sget-object v4, Landroidx/window/layout/FoldingFeature$State;->HALF_OPENED:Landroidx/window/layout/FoldingFeature$State;

    if-ne v2, v4, :cond_2

    sget-object v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;->g:Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;

    goto :goto_2

    :cond_2
    sget-object v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;->e:Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;

    :goto_2
    new-instance v4, Lio/flutter/embedding/engine/renderer/FlutterRenderer$b;

    invoke-interface {v1}, Landroidx/window/layout/DisplayFeature;->getBounds()Landroid/graphics/Rect;

    move-result-object v1

    invoke-direct {v4, v1, v3, v2}, Lio/flutter/embedding/engine/renderer/FlutterRenderer$b;-><init>(Landroid/graphics/Rect;Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;)V

    invoke-interface {v0, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    :cond_3
    new-instance v2, Lio/flutter/embedding/engine/renderer/FlutterRenderer$b;

    invoke-interface {v1}, Landroidx/window/layout/DisplayFeature;->getBounds()Landroid/graphics/Rect;

    move-result-object v1

    sget-object v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;->e:Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;

    sget-object v4, Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;->e:Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;

    invoke-direct {v2, v1, v3, v4}, Lio/flutter/embedding/engine/renderer/FlutterRenderer$b;-><init>(Landroid/graphics/Rect;Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;Lio/flutter/embedding/engine/renderer/FlutterRenderer$c;)V

    invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto/16 :goto_0

    :cond_4
    sget p1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1c

    if-lt p1, v1, :cond_5

    invoke-virtual {p0}, Landroid/widget/FrameLayout;->getRootWindowInsets()Landroid/view/WindowInsets;

    move-result-object p1

    if-eqz p1, :cond_5

    invoke-static {p1}, Landroidx/core/view/u;->a(Landroid/view/WindowInsets;)Landroid/view/DisplayCutout;

    move-result-object p1

    if-eqz p1, :cond_5

    invoke-virtual {p1}, Landroid/view/DisplayCutout;->getBoundingRects()Ljava/util/List;

    move-result-object p1

    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_3
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_5

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/graphics/Rect;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "DisplayCutout area reported with bounds = "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Landroid/graphics/Rect;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Lw/b;->f(Ljava/lang/String;Ljava/lang/String;)V

    new-instance v3, Lio/flutter/embedding/engine/renderer/FlutterRenderer$b;

    sget-object v4, Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;->h:Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;

    invoke-direct {v3, v1, v4}, Lio/flutter/embedding/engine/renderer/FlutterRenderer$b;-><init>(Landroid/graphics/Rect;Lio/flutter/embedding/engine/renderer/FlutterRenderer$d;)V

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_3

    :cond_5
    iget-object p1, p0, Lio/flutter/embedding/android/s;->s:Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;

    iput-object v0, p1, Lio/flutter/embedding/engine/renderer/FlutterRenderer$g;->q:Ljava/util/List;

    invoke-direct {p0}, Lio/flutter/embedding/android/s;->C()V

    return-void
.end method

.method public v()Z
    .locals 2

    iget-object v0, p0, Lio/flutter/embedding/android/s;->h:Lio/flutter/embedding/engine/a;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lio/flutter/embedding/engine/a;->s()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/embedding/android/s;->d:Lio/flutter/embedding/engine/renderer/b;

    invoke-interface {v1}, Lio/flutter/embedding/engine/renderer/b;->getAttachedRenderer()Lio/flutter/embedding/engine/renderer/FlutterRenderer;

    move-result-object v1

    if-ne v0, v1, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public y(Lio/flutter/embedding/engine/renderer/a;)V
    .locals 1

    iget-object v0, p0, Lio/flutter/embedding/android/s;->f:Ljava/util/Set;

    invoke-interface {v0, p1}, Ljava/util/Set;->remove(Ljava/lang/Object;)Z

    return-void
.end method
