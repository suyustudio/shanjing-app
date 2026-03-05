.class public final synthetic Lv/e;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lv/f;

.field public final synthetic e:Ljava/lang/String;


# direct methods
.method public synthetic constructor <init>(Lv/f;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lv/e;->d:Lv/f;

    iput-object p2, p0, Lv/e;->e:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    iget-object v0, p0, Lv/e;->d:Lv/f;

    iget-object v1, p0, Lv/e;->e:Ljava/lang/String;

    invoke-static {v0, v1}, Lv/f;->d(Lv/f;Ljava/lang/String;)V

    return-void
.end method
